FROM rust:1.87-bookworm

# install Noir
RUN apt -y update && apt -y install git 
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
RUN /root/.nargo/bin/noirup

# install co-snarks
RUN git clone https://github.com/TaceoLabs/co-snarks.git  && cd co-snarks/ && git checkout 1b2db005ee550c028af824b3ec4e811d6e8a3705 && cargo install --path co-noir/co-noir/ 
RUN rm -rf co-snarks

# download files for Demo
WORKDIR /app
RUN git clone https://github.com/TaceoLabs/noir_workshop_0625.git && mv noir_workshop_0625/* . && rm Dockerfile && rm noir_workshop_0625 -r

RUN mkdir out/
RUN mkdir out/secret-shared-inputs/
RUN mkdir out/merged-inputs/
RUN mkdir out/witness/
RUN mkdir out/proofs/

# install some quality of live (no, seriously they are great)
RUN cargo install bat
RUN cargo install just
