cmake -GNinja -DTON_USE_JEMALLOC=ON $1 \
  -DCMAKE_BUILD_TYPE=Release \
  -DOPENSSL_ROOT_DIR=$regularOpensslPath \
  -DOPENSSL_INCLUDE_DIR=$regularOpensslPath/include \
  -DOPENSSL_CRYPTO_LIBRARY=$regularOpensslPath/libcrypto.so

ninja fift smc-envelope
