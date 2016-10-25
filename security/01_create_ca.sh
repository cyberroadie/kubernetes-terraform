# wget https://pkg.cfssl.org/R1.2/cfssl_darwin-amd64
# chmod +x cfssl_darwin-amd64
# sudo mv cfssl_darwin-amd64 /usr/local/bin/cfssl

# wget https://pkg.cfssl.org/R1.2/cfssljson_darwin-amd64
# chmod +x cfssljson_darwin-amd64
# sudo mv cfssljson_darwin-amd64 /usr/local/bin/cfssljson

echo '{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}' > ca-config.json

echo '{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}' > ca-csr.json

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
openssl x509 -in ca.pem -text -noout
