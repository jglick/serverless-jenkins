FROM jenkins/jenkins
USER root
RUN apt-get update && \
    apt-get install -y \
        curl \
        chromium
USER jenkins
RUN jenkins-plugin-cli --plugins \
        git \
        pipeline-stage-step \
        workflow-basic-steps \
        workflow-durable-task-step \
        workflow-multibranch && \
    jenkins-plugin-cli --list
USER root
ENV JAVA_OPTS -Dhudson.Main.development=true
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "bash", "-ex", "/entrypoint.sh"]
