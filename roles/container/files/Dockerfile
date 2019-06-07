ARG BASE_IMAGE

FROM $BASE_IMAGE

RUN pip3 install --user snipsnip==0.8 && \
	ln -s ~/.local/bin/snipsnip ~/.local/bin/xsel && \
	ln -s ~/.local/bin/snipsnip ~/.local/bin/xclip
