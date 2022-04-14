FROM centos:7 AS base
RUN yum -y update
RUN yum install -y \
        java-1.8.0-openjdk \
        java-1.8.0-openjdk-devel; \
        yum clean all
        
RUN useradd charen
USER charen
WORKDIR /home/charen/

FROM base AS build
COPY . /tmp/
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/
RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::"); \
    cd /tmp/;                                                           \
    ./mvnw -N io.takari:maven:wrapper;                                  \
    ./mvnw clean install;                                               \
    cp target/myapp_server-0.0.1-SNAPSHOT.jar /home/charen/myapp.jar ;     

FROM base AS final
COPY --from=build /home/charen/myapp.jar .
EXPOSE 8080
CMD java -jar myapp.jar