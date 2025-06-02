# ton-wasm-builder

1. Build the docker image `docker build . -t ton-wasm-builder`
2. Run the image, mounting the ton repo source `docker run -it -v /your/ton:/ton ton-wasm-builder /bin/bash`
3. Inside the container, you'll end up in the `/workspace` directory. Make a directory for regular (non-wasm) builds (required to generate auto-generated files), cd into it, and build smc-envelope `mkdir regular && cd regular && ../build-smc-envelope.sh /ton`
4. Still inside the container, create another build directory (for wasm), and build it `mkdir ../wasm && cd ../wasm && . ../configure-wasm-build.sh && emmake make funcfiftlib` Note that unlike the previous step, this step's script exports important env vars, so you need to run it using `.` or `source` and not directly. Since it exports some envs, it might break regular builds if you try doing them after that, but I'm not really sure. You shouldn't need regular builds after this unless ton is updated significantly.
5. Copy out the build artifacts - the easiest way is to copy them into the mounted `/ton` directory