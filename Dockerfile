FROM continuumio/miniconda3
RUN apt-get update && apt-get install -y build-essential

WORKDIR /app

COPY environments/environment.yml ./environment.yml
RUN conda env create -f environment.yml -n tts; rm environment.yml

COPY deepvoice3_pytorch ./deepvoice3_pytorch

SHELL ["conda", "run", "-n", "tts", "/bin/bash", "-c"]
RUN pip install --no-deps -e "deepvoice3_pytorch/[bin]" && \
    python -c "import nltk; nltk.download(\"punkt\"); nltk.download(\"cmudict\")";
SHELL ["/bin/bash", "-c"]

VOLUME /app/models
COPY . .

RUN echo "python tts_worker.py --log-config config/logging.ini --worker-config config/config.yaml"  > entrypoint.sh

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "tts", "bash", "entrypoint.sh"]