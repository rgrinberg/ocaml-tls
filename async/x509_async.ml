open Core.Std
open Async.Std

type priv = X509.t list * Nocrypto.Rsa.priv

type authenticator = X509.Authenticator.a

let read_cstruct f =
  f
  |> Reader.file_contents
  >>| (fun s -> Cstruct.of_string s)

let private_of_pems ~cert ~priv_key =
  let open X509.Encoding.Pem in
  Deferred.both (read_cstruct cert) (read_cstruct priv_key)
  >>| (fun (cert, priv_key) ->
      let cert = Certificate.of_pem_cstruct cert in
      let (`RSA key) = Private_key.of_pem_cstruct1 priv_key in
      (cert, key)
    )

let certs_of_pem path =
  path
  |> read_cstruct
  >>| X509.Encoding.Pem.Certificate.of_pem_cstruct

let certs_of_pem_dir path =
  path
  |> Sys.readdir
  >>| (Fn.compose
         Array.to_list
         (Array.filter ~f:(fun x -> Caml.Filename.extension x = "crt")))
  >>= Deferred.List.concat_map ~how:`Parallel ~f:(fun f ->
      certs_of_pem (Filename.concat path f)
    )

let authenticator param =
  let now = Unix.gettimeofday () in
  let of_cas cas =
    X509.Authenticator.chain_of_trust ~time:now cas in
  let dotted_hex_to_cs hex =
    Nocrypto.Uncommon.Cs.of_hex
      (String.map hex ~f:(function ':' -> ' ' | x -> x)) in
  let fingerp hash fingerprints =
    X509.Authenticator.server_key_fingerprint ~time:now ~hash ~fingerprints
  in
  match param with
  | `Ca_file path -> certs_of_pem path >>| of_cas
  | `Ca_dir path  -> certs_of_pem_dir path >>| of_cas
  | `Key_fingerprints (hash, fps) -> return (fingerp hash fps)
  | `Hex_key_fingerprints (hash, fps) ->
    let fps = List.map ~f:(fun (n, v) -> (n, dotted_hex_to_cs v)) fps in
    return (fingerp hash fps)
  | `No_authentication_I'M_STUPID -> return X509.Authenticator.null
