FROM debian:stretch

# Install pygments (for syntax highlighting)
RUN apt-get -qq update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends openssh-client python-pygments git ca-certificates asciidoc curl \
	&& rm -rf /var/lib/apt/lists/*

# Install Git LFS
RUN build_deps="curl ca-certificates"  \
    && apt-get update  \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash  \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs \
    && git lfs install  \
    && rm -r /var/lib/apt/lists/*

# Install TexLive
RUN apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq install -y texlive-latex-base texlive-generic-recommended \
    	texlive-generic-extra texlive-fonts-recommended  texlive-latex-extra texlive-lang-german texlive-lang-english  \
    	texlive-fonts-extra texlive-font-utils texlive-extra-utils texlive-bibtex-extra texlive-xetex texlive-luatex \
    && rm -rf /usr/share/doc/* \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq install -y Python3.6 \
    && rm -rf /var/lib/apt/lists/*

# Install Pandoc
RUN apt-get update \
 	&& DEBIAN_FRONTEND=noninteractive && apt-get -qq install -y pandoc \
	&& rm -rf /var/lib/apt/lists/*

# Install pandoc crossref
RUN apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq install -y wget \
    && wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.3.0/linux-ghc84-pandoc23.tar.gz \
    && tar xvf linux-ghc84-pandoc23.tar.gz \
    && mv pandoc-crossref* /usr/bin/ \
    && rm linux-ghc84-pandoc23.tar.gz \
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq -y remove wget  \
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq -y autoremove \
    && rm -rf /var/lib/apt/lists/*


#asdf
