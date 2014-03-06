open Asn

type bits = Cstruct.t

let def  x = function None -> x | Some y -> y
let def' x = fun y -> if y = x then None else Some y

let projections encoding asn =
  let c = codec encoding asn in
  (decode c, encode c)

module ID = struct

  (*
   * Object Identifiers: magic numbers with a tie. Some OIDs also have an MBA.
   *
   * http://www.alvestrand.no/objectid/
   * http://oid-info.com/
   *)

  let usa    = OID.(base 1 2 <| 840)
  let rsadsi = OID.(usa <| 113549)
  let pkcs   = OID.(rsadsi <| 1)

  (* PKCS1 *)

  let md2   = OID.(rsadsi <| 2 <| 2)
  let md5   = OID.(rsadsi <| 2 <| 5)
  let sha1  = OID.(base 1 3 <| 14 <| 3 <| 2 <| 26)

  (* rfc5758 *)

  let sha256, sha384, sha512, sha224, sha512_224, sha512_256 =
    let pre =
      OID.(base 2 16 <| 840 <| 1 <| 101 <| 3 <| 4 <| 2) in
    OID.( pre <| 1, pre <| 2, pre <| 3, pre <| 4, pre <| 5, pre <| 6 )

  module ANSI_X9_62 = struct

    let ansi_x9_62 = OID.(usa <| 10045)

    let ecdsa_sha1             = OID.(ansi_x9_62 <| 1)
    let prime_field            = OID.(ecdsa_sha1 <| 1)
    let characteristic_2_field = OID.(ecdsa_sha1 <| 2)

    let key_type   = OID.(ansi_x9_62 <| 2)
    let ec_pub_key = OID.(key_type <| 1)

    let signatures = OID.(ansi_x9_62 <| 4)
    let field_type = OID.(signatures <| 1)
    let ecdsa_sha2 = OID.(signatures <| 3)

    let ecdsa_sha224 = OID.(ecdsa_sha2 <| 1)
    let ecdsa_sha256 = OID.(ecdsa_sha2 <| 2)
    let ecdsa_sha384 = OID.(ecdsa_sha2 <| 3)
    let ecdsa_sha512 = OID.(ecdsa_sha2 <| 4)
  end

  module PKCS1 = struct
    let pkcs1 = OID.(pkcs <| 1)

    let rsa_encryption           = OID.(pkcs1 <| 1 )
    and md2_rsa_encryption       = OID.(pkcs1 <| 2 )
    and md4_rsa_encryption       = OID.(pkcs1 <| 3 )
    and md5_rsa_encryption       = OID.(pkcs1 <| 4 )
    and sha1_rsa_encryption      = OID.(pkcs1 <| 5 )
    and ripemd160_rsa_encryption = OID.(pkcs1 <| 6 )
    and rsaes_oaep               = OID.(pkcs1 <| 7 )
    and rsassa_pss               = OID.(pkcs1 <| 10)
    and sha256_rsa_encryption    = OID.(pkcs1 <| 11)
    and sha384_rsa_encryption    = OID.(pkcs1 <| 12)
    and sha512_rsa_encryption    = OID.(pkcs1 <| 13)
    and sha224_rsa_encryption    = OID.(pkcs1 <| 14)
  end

  module PKCS2 = struct
    let pkcs2 = OID.(rsadsi <| 2)

    let md4         = OID.(pkcs2 <| 4 )
    and hmac_sha1   = OID.(pkcs2 <| 7 )
    and hmac_sha224 = OID.(pkcs2 <| 8 )
    and hmac_sha256 = OID.(pkcs2 <| 9 )
    and hmac_sha384 = OID.(pkcs2 <| 10)
    and hmac_sha512 = OID.(pkcs2 <| 11)
  end

  module PKCS5 = struct
    let pkcs5 = OID.(pkcs <| 5)

    let pbe_md2_des_cbc  = OID.(pkcs5 <| 1 )
    and pbe_md5_des_cbc  = OID.(pkcs5 <| 3 )
    and pbe_md2_rc2_cbc  = OID.(pkcs5 <| 4 )
    and pbe_md5_rc2_cbc  = OID.(pkcs5 <| 6 )
    and pbe_md5_xor      = OID.(pkcs5 <| 9 )
    and pbe_sha1_des_cbc = OID.(pkcs5 <| 10)
    and pbe_sha1_rc2_cbc = OID.(pkcs5 <| 11)
    and pbkdf2           = OID.(pkcs5 <| 12)
    and pbes2            = OID.(pkcs5 <| 13)
    and pbmac1           = OID.(pkcs5 <| 14)
  end

  module PKCS7 = struct
    let pkcs7 = OID.(pkcs <| 7)

    let data                   = OID.(pkcs7 <| 1)
    and signedData             = OID.(pkcs7 <| 2)
    and envelopedData          = OID.(pkcs7 <| 3)
    and signedAndEnvelopedData = OID.(pkcs7 <| 4)
    and digestedData           = OID.(pkcs7 <| 5)
    and encryptedData          = OID.(pkcs7 <| 6)
  end

  module PKCS9 = struct
    let pkcs9 = OID.(pkcs <| 9)

    let email                = OID.(pkcs9 <| 1 )
    and unstructured_name    = OID.(pkcs9 <| 2 )
    and content_type         = OID.(pkcs9 <| 3 )
    and message_digest       = OID.(pkcs9 <| 4 )
    and signing_time         = OID.(pkcs9 <| 5 )
    and challenge_password   = OID.(pkcs9 <| 7 )
    and unstructured_address = OID.(pkcs9 <| 8 )
    and signing_description  = OID.(pkcs9 <| 13)
    and extension_request    = OID.(pkcs9 <| 14)
    and smime_capabilities   = OID.(pkcs9 <| 15)
    and smime_oid_registry   = OID.(pkcs9 <| 16)
    and friendly_name        = OID.(pkcs9 <| 20)
    and cert_types           = OID.(pkcs9 <| 22)
  end

  module X520 = struct
    let x520 = OID.(base 2 5 <| 4)

    let object_class                  = OID.(x520 <| 0 )
    and aliased_entry_name            = OID.(x520 <| 1 )
    and knowldgeinformation           = OID.(x520 <| 2 )
    and common_name                   = OID.(x520 <| 3 )
    and surname                       = OID.(x520 <| 4 )
    and serial_number                 = OID.(x520 <| 5 )
    and country_name                  = OID.(x520 <| 6 )
    and locality_name                 = OID.(x520 <| 7 )
    and state_or_province_name        = OID.(x520 <| 8 )
    and street_address                = OID.(x520 <| 9 )
    and organization_name             = OID.(x520 <| 10)
    and organizational_unit_name      = OID.(x520 <| 11)
    and title                         = OID.(x520 <| 12)
    and description                   = OID.(x520 <| 13)
    and search_guide                  = OID.(x520 <| 14)
    and business_category             = OID.(x520 <| 15)
    and postal_address                = OID.(x520 <| 16)
    and postal_code                   = OID.(x520 <| 17)
    and post_office_box               = OID.(x520 <| 18)
    and physical_delivery_office_name = OID.(x520 <| 19)
    and telephone_number              = OID.(x520 <| 20)
    and telex_number                  = OID.(x520 <| 21)
    and teletex_terminal_identifier   = OID.(x520 <| 22)
    and facsimile_telephone_number    = OID.(x520 <| 23)
    and x121_address                  = OID.(x520 <| 24)
    and internationa_isdn_number      = OID.(x520 <| 25)
    and registered_address            = OID.(x520 <| 26)
    and destination_indicator         = OID.(x520 <| 27)
    and preferred_delivery_method     = OID.(x520 <| 28)
    and presentation_address          = OID.(x520 <| 29)
    and supported_application_context = OID.(x520 <| 30)
    and member                        = OID.(x520 <| 31)
    and owner                         = OID.(x520 <| 32)
    and role_occupant                 = OID.(x520 <| 33)
    and see_also                      = OID.(x520 <| 34)
    and user_password                 = OID.(x520 <| 35)
    and user_certificate              = OID.(x520 <| 36)
    and ca_certificate                = OID.(x520 <| 37)
    and authority_revocation_list     = OID.(x520 <| 38)
    and certificate_revocation_list   = OID.(x520 <| 39)
    and cross_certificate_pair        = OID.(x520 <| 40)
    and name                          = OID.(x520 <| 41)
    and given_name                    = OID.(x520 <| 42)
    and initials                      = OID.(x520 <| 43)
    and generation_qualifier          = OID.(x520 <| 44)
    and unique_identifier             = OID.(x520 <| 45)
    and dn_qualifier                  = OID.(x520 <| 46)
    and enhanced_search_guide         = OID.(x520 <| 47)
    and protocol_information          = OID.(x520 <| 48)
    and distinguished_name            = OID.(x520 <| 49)
    and unique_member                 = OID.(x520 <| 50)
    and house_identifier              = OID.(x520 <| 51)
    and supported_algorithms          = OID.(x520 <| 52)
    and delta_revocation_list         = OID.(x520 <| 53)
    and attribute_certificate         = OID.(x520 <| 58)
    and pseudonym                     = OID.(x520 <| 65)
  end

end


(*
 * RSA
 *)

(* the no-decode integer, assuming >= 0 and DER. *)
let nat =
  let f cs =
    Cstruct.(to_string @@
              if get_uint8 cs 0 = 0x00 then shift cs 1 else cs)
  and g str =
    assert false in
  map f g @@
    implicit ~cls:`Universal 0x02 octet_string

let other_prime_infos =
  sequence_of @@
    (sequence3
      (required ~label:"prime"       nat)
      (required ~label:"exponent"    nat)
      (required ~label:"coefficient" nat))

let rsa_private_key =
  let open Cryptokit.RSA in

  let f (_, (n, (e, (d, (p, (q, (dp, (dq, (qinv, _))))))))) =
    let size = String.length n * 8 in
    { size; n; e; d; p; q; dp; dq; qinv }

  and g { size; n; e; d; p; q; dp; dq; qinv } =
    (0, (n, (e, (d, (p, (q, (dp, (dq, (qinv, None))))))))) in

  map f g @@
  sequence @@
      (required ~label:"version"         int)
    @ (required ~label:"modulus"         nat)       (* n    *)
    @ (required ~label:"publicExponent"  nat)       (* e    *)
    @ (required ~label:"privateExponent" nat)       (* d    *)
    @ (required ~label:"prime1"          nat)       (* p    *)
    @ (required ~label:"prime2"          nat)       (* q    *)
    @ (required ~label:"exponent1"       nat)       (* dp   *)
    @ (required ~label:"exponent2"       nat)       (* dq   *)
    @ (required ~label:"coefficient"     nat)       (* qinv *)
   -@ (optional ~label:"otherPrimeInfos" other_prime_infos)


let rsa_public_key =
  let open Cryptokit.RSA in

  let f (n, e) =
    let size = String.length n * 8 in
    { size; n; e; d = ""; p = ""; q = ""; dp = ""; dq = ""; qinv = "" }

  and g { n; e } = (n, e) in

  map f g @@
  sequence2
    (required ~label:"modulus"        nat)
    (required ~label:"publicExponent" nat)

let (rsa_private_of_cstruct, rsa_private_to_cstruct) =
  projections der rsa_private_key

let (rsa_public_of_cstruct, rsa_public_to_cstruct) =
  projections der rsa_public_key


(*
 * X509 certs
 *)

type algorithm =
  (* pk algos *)
  | RSA
  | EC_pub_key of OID.t (* should translate the oid too *)
  (* sig algos *)
  | MD2_RSA
  | MD4_RSA
  | MD5_RSA
  | RIPEMD160_RSA
  | SHA1_RSA
  | SHA256_RSA
  | SHA384_RSA
  | SHA512_RSA
  | SHA224_RSA
  | ECDSA_SHA1
  | ECDSA_SHA224
  | ECDSA_SHA256
  | ECDSA_SHA384
  | ECDSA_SHA512

type tBSCertificate = {
  version    : [ `V1 | `V2 | `V3 ] ;
  serial     : Num.num ;
  signature  : algorithm ;
  issuer     : (oid * string) list list ;
  validity   : time * time ;
  subject    : (oid * string) list list ;
  pk_info    : algorithm * bits ;
  issuer_id  : bits option ;
  subject_id : bits option ;
  extensions : (oid * bool * Cstruct.t) list option
}

type certificate = {
  tbs_cert       : tBSCertificate ;
  signature_algo : algorithm ;
  signature_val  : bits
}

(* XXX
 *
 * PKCS1/RFC5280 allows params to be `ANY', depending on the algorithm.  I don't
 * know of one that uses anything other than NULL and OID, however, so we accept
 * only that.
 *)

let algorithmIdentifier =
  let open ID in

  let unit = Some (`C1 ()) in

  let f = function
    | (oid, Some (`C2 oid')) when oid = ANSI_X9_62.ec_pub_key -> EC_pub_key oid'
    | (oid, _) when oid = PKCS1.rsa_encryption  -> RSA

    | (oid, _) when oid = PKCS1.md2_rsa_encryption       -> MD2_RSA
    | (oid, _) when oid = PKCS1.md4_rsa_encryption       -> MD4_RSA
    | (oid, _) when oid = PKCS1.md5_rsa_encryption       -> MD5_RSA
    | (oid, _) when oid = PKCS1.ripemd160_rsa_encryption -> RIPEMD160_RSA
    | (oid, _) when oid = PKCS1.sha1_rsa_encryption      -> SHA1_RSA
    | (oid, _) when oid = PKCS1.sha256_rsa_encryption    -> SHA256_RSA
    | (oid, _) when oid = PKCS1.sha384_rsa_encryption    -> SHA384_RSA
    | (oid, _) when oid = PKCS1.sha512_rsa_encryption    -> SHA512_RSA
    | (oid, _) when oid = PKCS1.sha224_rsa_encryption    -> SHA224_RSA

    | (oid, _) when oid = ANSI_X9_62.ecdsa_sha1   -> ECDSA_SHA1
    | (oid, _) when oid = ANSI_X9_62.ecdsa_sha224 -> ECDSA_SHA224
    | (oid, _) when oid = ANSI_X9_62.ecdsa_sha256 -> ECDSA_SHA256
    | (oid, _) when oid = ANSI_X9_62.ecdsa_sha384 -> ECDSA_SHA384
    | (oid, _) when oid = ANSI_X9_62.ecdsa_sha512 -> ECDSA_SHA512

    | (oid, _) -> parse_error @@
        Printf.sprintf "unknown algorithm (%s) or unexpected params"
                       (OID.to_string oid)

  and g = function
    | EC_pub_key id -> (ANSI_X9_62.ec_pub_key, Some (`C2 id))
    | RSA           -> (PKCS1.rsa_encryption           , unit)
    | MD2_RSA       -> (PKCS1.md2_rsa_encryption       , unit)
    | MD4_RSA       -> (PKCS1.md4_rsa_encryption       , unit)
    | MD5_RSA       -> (PKCS1.md5_rsa_encryption       , unit)
    | RIPEMD160_RSA -> (PKCS1.ripemd160_rsa_encryption , unit)
    | SHA1_RSA      -> (PKCS1.sha1_rsa_encryption      , unit)
    | SHA256_RSA    -> (PKCS1.sha256_rsa_encryption    , unit)
    | SHA384_RSA    -> (PKCS1.sha384_rsa_encryption    , unit)
    | SHA512_RSA    -> (PKCS1.sha512_rsa_encryption    , unit)
    | SHA224_RSA    -> (PKCS1.sha224_rsa_encryption    , unit)
    | ECDSA_SHA1    -> (ANSI_X9_62.ecdsa_sha1          , unit)
    | ECDSA_SHA224  -> (ANSI_X9_62.ecdsa_sha224        , unit)
    | ECDSA_SHA256  -> (ANSI_X9_62.ecdsa_sha256        , unit)
    | ECDSA_SHA384  -> (ANSI_X9_62.ecdsa_sha384        , unit)
    | ECDSA_SHA512  -> (ANSI_X9_62.ecdsa_sha512        , unit)
  in

  map f g @@
  sequence2
    (required ~label:"algorithm" oid)
    (optional ~label:"params"
      (choice2 null oid))

let extensions =
  let extension =
    map (fun (oid, b, v) -> (oid, def  false b, v))
        (fun (oid, b, v) -> (oid, def' false b, v)) @@
    sequence3
      (required ~label:"id"       oid)
      (optional ~label:"critical" bool) (* default false *)
      (required ~label:"value"    octet_string)
  in
  sequence_of extension


let directory_name =
  let f = function | `C1 s -> s | `C2 s -> s | `C3 s -> s
                   | `C4 s -> s | `C5 s -> s | `C6 s -> s
  and g s = `C1 s in
  map f g @@
  choice6
    utf8_string printable_string
    (* The following three could probably be ommited.
      * See rfc5280 section 4.1.2.4. *)
    universal_string teletex_string bmp_string
    (* is this standard? *)
    ia5_string

let name =
  let attribute_tv =
   sequence2
      (required ~label:"attr type"  oid)
      (* This is ANY according to rfc5280. *)
      (required ~label:"attr value" directory_name) in
  let rd_name      = set_of attribute_tv in
  let rdn_sequence = sequence_of rd_name in
  rdn_sequence (* A vacuous choice, in the standard. *)

let version =
  map (function 2 -> `V2 | 3 -> `V3 | _ -> `V1)
      (function `V2 -> 2 | `V3 -> 3 | _ -> 1)
  int

let certificateSerialNumber = integer

let time =
  map (function `C1 t -> t | `C2 t -> t) (fun t -> `C2 t)
      (choice2 utc_time generalized_time)

let validity =
  sequence2
    (required ~label:"not before" time)
    (required ~label:"not after"  time)

let subjectPublicKeyInfo =
  sequence2
    (required ~label:"algorithm" algorithmIdentifier)
    (required ~label:"subjectPK" bit_string')

let uniqueIdentifier = bit_string'

let tBSCertificate =
  let f = fun (a, (b, (c, (d, (e, (f, (g, (h, (i, j))))))))) ->
    { version    = def `V1 a ; serial     = b ;
      signature  = c         ; issuer     = d ;
      validity   = e         ; subject    = f ;
      pk_info    = g         ; issuer_id  = h ;
      subject_id = i         ; extensions = j }

  and g = fun
    { version    = a ; serial     = b ;
      signature  = c ; issuer     = d ;
      validity   = e ; subject    = f ;
      pk_info    = g ; issuer_id  = h ;
      subject_id = i ; extensions = j } ->
    (def' `V1 a, (b, (c, (d, (e, (f, (g, (h, (i, j)))))))))
  in

  map f g @@
  sequence @@
      (optional ~label:"version"       @@ explicit 0 version) (* default v1 *)
    @ (required ~label:"serialNumber"  @@ certificateSerialNumber)
    @ (required ~label:"signature"     @@ algorithmIdentifier)
    @ (required ~label:"issuer"        @@ name)
    @ (required ~label:"validity"      @@ validity)
    @ (required ~label:"subject"       @@ name)
    @ (required ~label:"subjectPKInfo" @@ subjectPublicKeyInfo)
      (* if present, version is v2 or v3 *)
    @ (optional ~label:"issuerUID"     @@ implicit 1 uniqueIdentifier)
      (* if present, version is v2 or v3 *)
    @ (optional ~label:"subjectUID"    @@ implicit 2 uniqueIdentifier)
      (* v3 if present *)
   -@ (optional ~label:"extensions"    @@ explicit 3 extensions)

let (tbs_certificate_of_cstruct, tbs_certificate_to_cstruct) =
  projections ber tBSCertificate


let certificate =

  let f (a, b, c) =
    if a.signature <> b then
      parse_error "signatureAlgorithm != tbsCertificate.signature"
    else
      { tbs_cert = a; signature_algo = b; signature_val = c }

  and g { tbs_cert = a; signature_algo = b; signature_val = c } = (a, b, c) in

  map f g @@
  sequence3
    (required ~label:"tbsCertificate"     tBSCertificate)
    (required ~label:"signatureAlgorithm" algorithmIdentifier)
    (required ~label:"signatureValue"     bit_string')

let (certificate_of_cstruct, certificate_to_cstruct) =
  projections ber certificate

let rsa_public_of_cert cert =
  let oid, bits = cert.tbs_cert.pk_info in
  (* XXX check if oid is actually rsa *)
  match rsa_public_of_cstruct bits with
  | Some (k, _) -> k
  | None -> assert false


let pkcs1_digest_info =
  sequence2
    (required ~label:"digestAlgorithm" algorithmIdentifier)
    (required ~label:"digest"          octet_string)

let (pkcs1_digest_info_of_cstruct, pkcs1_digest_info_to_cstruct) =
  projections der pkcs1_digest_info

