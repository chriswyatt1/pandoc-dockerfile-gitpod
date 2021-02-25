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
    && DEBIAN_FRONTEND=noninteractive && apt-get -qq install -y Python3.9 python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Pandoc
RUN apt-get update && apt-get install ghc cabal-install -y \
		    && cabal update  \
			&& cabal install pandoc-types \
		    && echo export PATH='$PATH:$HOME/.cabal/bin' >> $HOME/.bashrc \
		    && echo export PATH='$PATH:$HOME/.cabal/bin' >> $HOME/.profile \
			&& rm -rf /var/lib/apt/lists/*

		RUN apt-get update && apt-get install wget -y \
			&& wget https://github.com/jgm/pandoc/releases/download/2.11/pandoc-2.11-1-amd64.deb \
			&& dpkg -i pandoc-2.11-1-amd64.deb \
			&& rm pandoc-2.11-1-amd64.deb

# Install pandoc crossref
RUN sudo apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive && sudo apt-get -qq install -y wget \
    && sudo wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.8.2/pandoc-crossref-Linux.tar.xz \
    && sudo tar xvf pandoc-crossref-Linux.tar.xz \
    && sudo rm pandoc-crossref-Linux.tar.xz \
    && sudo mv pandoc-crossref* /usr/bin/ \
    && DEBIAN_FRONTEND=noninteractive && sudo apt-get -qq -y remove wget  \
    && DEBIAN_FRONTEND=noninteractive && sudo apt-get -qq -y autoremove \
    && sudo rm -rf /var/lib/apt/lists/*


#asdf
