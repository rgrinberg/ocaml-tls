(** Core type definitions *)

open Sexplib.Conv
open Nocrypto

open Packet
open Ciphersuite

type tls_version =
  | TLS_1_0
  | TLS_1_1
  | TLS_1_2
  | TLS_1_3
  [@@deriving sexp]

let pair_of_tls_version = function
  | TLS_1_0   -> (3, 1)
  | TLS_1_1   -> (3, 2)
  | TLS_1_2   -> (3, 3)
  | TLS_1_3   -> (3, 4)

let tls_version_of_pair = function
  | (3, 1) -> Some TLS_1_0
  | (3, 2) -> Some TLS_1_1
  | (3, 3) -> Some TLS_1_2
  | (3, 4) -> Some TLS_1_3
  | _      -> None

let draft = 0x000c

type tls_any_version =
  | SSL_3
  | Supported of tls_version
  | TLS_1_X of int
  [@@deriving sexp]

let any_version_to_version = function
  | Supported v -> Some v
  | _           -> None

let version_eq a b =
  match a with
  | Supported x -> x = b
  | _           -> false

let version_ge a b =
  match a with
  | Supported x -> x >= b
  | SSL_3       -> false
  | TLS_1_X _   -> true

let tls_any_version_of_pair x =
  match tls_version_of_pair x with
  | Some v -> Some (Supported v)
  | None ->
     match x with
     | (3, 0) -> Some SSL_3
     | (3, x) -> Some (TLS_1_X x)
     | _      -> None

let pair_of_tls_any_version = function
  | Supported x -> pair_of_tls_version x
  | SSL_3       -> (3, 0)
  | TLS_1_X m   -> (3, m)

let max_protocol_version (_, hi) = hi
let min_protocol_version (lo, _) = lo

type tls_hdr = {
  content_type : content_type;
  version      : tls_any_version;
} [@@deriving sexp]

module SessionID = struct
  type t = Cstruct.t [@@deriving sexp]
  let compare = Cstruct.compare
  let hash t = Hashtbl.hash (Cstruct.to_bigarray t)
  let equal = Cstruct.equal
end

module PreSharedKeyID = struct
  type t = Cstruct.t [@@deriving sexp]
  let compare = Cstruct.compare
  let hash t = Hashtbl.hash (Cstruct.to_bigarray t)
  let equal = Cstruct.equal
end

type early_data = {
  configuration_id : Cstruct.t ;
  ciphersuite : ciphersuite ;
  extensions : Cstruct.t ; (* XXX: extensions! *)
  context : Cstruct.t ;
} [@@deriving sexp]

type psk_identity = Cstruct.t [@@deriving sexp]

type group = Nocrypto.Dh.group [@@deriving sexp] (* for now *)

type client_extension = [
  | `Hostname of string
  | `MaxFragmentLength of max_fragment_length
  | `SupportedGroups of named_group list
  | `ECPointFormats of ec_point_format list
  | `SecureRenegotiation of Cstruct.t
  | `Padding of int
  | `SignatureAlgorithms of (Hash.hash * signature_algorithm_type) list
  | `ExtendedMasterSecret
  | `KeyShare of (named_group * Cstruct.t) list
  | `EarlyDataIndication of early_data
  | `PreSharedKey of psk_identity list
  | `Draft of int
  | `UnknownExtension of (int * Cstruct.t)
] [@@deriving sexp]

type server_extension = [
  | `Hostname
  | `MaxFragmentLength of max_fragment_length
  | `ECPointFormats of ec_point_format list
  | `SecureRenegotiation of Cstruct.t
  | `ExtendedMasterSecret
  | `KeyShare of (group * Cstruct.t)
  | `EarlyDataIndication
  | `PreSharedKey of psk_identity
  | `Draft of int
  | `UnknownExtension of (int * Cstruct.t)
] [@@deriving sexp]

type client_hello = {
  client_version : tls_any_version;
  client_random  : Cstruct.t;
  sessionid      : SessionID.t option;
  ciphersuites   : any_ciphersuite list;
  extensions     : client_extension list
} [@@deriving sexp]

type server_hello = {
  server_version : tls_version;
  server_random  : Cstruct.t;
  sessionid      : SessionID.t option;
  ciphersuite    : ciphersuite;
  extensions     : server_extension list
} [@@deriving sexp]

type dh_parameters = {
  dh_p  : Cstruct.t;
  dh_g  : Cstruct.t;
  dh_Ys : Cstruct.t;
} [@@deriving sexp]

type ec_curve = {
  a : Cstruct.t;
  b : Cstruct.t
} [@@deriving sexp]

type ec_prime_parameters = {
  prime    : Cstruct.t;
  curve    : ec_curve;
  base     : Cstruct.t;
  order    : Cstruct.t;
  cofactor : Cstruct.t;
  public   : Cstruct.t
} [@@deriving sexp]

type ec_char_parameters = {
  m        : int;
  basis    : ec_basis_type;
  ks       : Cstruct.t list;
  curve    : ec_curve;
  base     : Cstruct.t;
  order    : Cstruct.t;
  cofactor : Cstruct.t;
  public   : Cstruct.t
} [@@deriving sexp]

type ec_parameters =
  | ExplicitPrimeParameters of ec_prime_parameters
  | ExplicitCharParameters of ec_char_parameters
  | NamedGroupParameters of (group * Cstruct.t)
  [@@deriving sexp]

type hello_retry_request = {
  version : tls_version ;
  ciphersuite : ciphersuite ;
  selected_group : group ;
  extensions : server_extension list
} [@@deriving sexp]

type server_configuration = {
  configuration_id : Cstruct.t ;
  expiration_date : Cstruct.t ;
  key_share : (group * Cstruct.t) ;
  early_data_type : early_data_type ;
  extensions : Cstruct.t ; (* XXX: configuration_extension list *)
} [@@deriving sexp]

type tls_handshake =
  | HelloRequest
  | HelloRetryRequest of hello_retry_request
  | EncryptedExtensions of server_extension list
  | ServerHelloDone
  | ClientHello of client_hello
  | ServerHello of server_hello
  | Certificate of Cstruct.t
  | ServerKeyExchange of Cstruct.t
  | CertificateRequest of Cstruct.t
  | ClientKeyExchange of Cstruct.t
  | CertificateVerify of Cstruct.t
  | Finished of Cstruct.t
  | SessionTicket of Cstruct.t
  | ServerConfiguration of server_configuration
  | KeyUpdate
  [@@deriving sexp]

type tls_alert = alert_level * alert_type [@@deriving sexp]

type tls_body =
  | TLS_ChangeCipherSpec
  | TLS_ApplicationData
  | TLS_Alert of tls_alert
  | TLS_Handshake of tls_handshake
  [@@deriving sexp]

(** the master secret of a TLS connection *)
type master_secret = Cstruct.t [@@deriving sexp]

(** information about an open session *)
type epoch_data = {
  protocol_version       : tls_version ;
  ciphersuite            : Ciphersuite.ciphersuite ;
  peer_random            : Cstruct.t ;
  peer_certificate_chain : X509.t list ;
  peer_certificate       : X509.t option ;
  peer_name              : string option ;
  trust_anchor           : X509.t option ;
  received_certificates  : X509.t list ;
  own_random             : Cstruct.t ;
  own_certificate        : X509.t list ;
  own_private_key        : Nocrypto.Rsa.priv option ;
  own_name               : string option ;
  master_secret          : master_secret ;
  session_id             : SessionID.t ;
  extended_ms            : bool ;
  resumption_secret      : Cstruct.t ;
  psk_id                 : PreSharedKeyID.t ;
} [@@deriving sexp]
