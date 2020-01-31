#!/bin/bash

# S3_BUCKET - srev-emr/repository/releases/1.2-release
install_file() {
    local path_in_s3="$1"; shift
    local target_dir="$1"; shift
    local file_name="$(basename "$path_in_s3")"
    local http_url_in_s3="$(echo "$path_in_s3" | sed "s|^s3://\([^/]\+\)/|http://\1.s3.amazonaws.com/|")"

    echo "Installing file $file_name from S3 into $target_dir/..."
    sudo mkdir -p "$target_dir" && \
    aws s3 cp "$path_in_s3" /tmp/ && \
    sudo mv "/tmp/$file_name" "$target_dir/"
}

S3_BUCKET="srev-emr"

echo "args: $@"

while getopts ":b:" opt; do
  case $opt in
    b)
      S3_BUCKET=$OPTARG
      echo "S3_BUCKET was given as '$S3_BUCKET'"
      ;;
  esac
done

# Adapted from https://wiki.ssi-cloud.com/display/OPSDOC/How+to+provision+a+new+Ambari+cluster
BOOTSTRAP_FILES_S3="s3://$S3_BUCKET/dependencies"
install_file $BOOTSTRAP_FILES_S3/mongo-hadoop-core.jar /usr/lib/hadoop/lib
install_file $BOOTSTRAP_FILES_S3/mongo-hadoop-hive.jar /usr/lib/hadoop/lib
install_file $BOOTSTRAP_FILES_S3/mongo-java-driver.jar /usr/lib/hadoop/lib
install_file $BOOTSTRAP_FILES_S3/ssi-spiderserdetool-service.jar /usr/lib/hadoop/lib
sudo chown root:root /usr/lib/hadoop/lib/mongo-*.jar /usr/lib/hadoop/lib/ssi-*.jar
install_file s3://$S3_BUCKET/bootstrap-actions/ca.crt /etc/hue

install_file $BOOTSTRAP_FILES_S3/hadoopoffice-hiveserde.jar /usr/lib/hive/lib/
install_file $BOOTSTRAP_FILES_S3/hadoopoffice-hiveserde.jar /usr/lib/hadoop/lib/
install_file $BOOTSTRAP_FILES_S3/mysql-connector-java.jar /usr/lib/hive/lib/
sudo chmod 777 /usr/lib/hive/lib/mysql-connector-java.jar
sudo chmod 777 /usr/lib/hive/lib/hadoopoffice-hiveserde.jar
sudo chmod 777 /usr/lib/hadoop/lib/hadoopoffice-hiveserde.jar
install_file $BOOTSTRAP_FILES_S3/presto-jdbc.jar /usr/lib/jvm/java/jre/lib/ext
sudo chown root:root /usr/lib/jvm/java/jre/lib/ext/presto-jdbc.jar      
#SET hive.execution.engine=tez;

sudo yum -y install pigz

######################################NTP CONFIG GOES HERE######################################
NTP_CONFIG_LOCATION_S3="s3://$S3_BUCKET/bootstrap-actions"
CONFIG_NTP_BOOTSTRAP_S3="$NTP_CONFIG_LOCATION_S3/ntp.conf"
KEY_NTP_BOOTSTRAP_S3="$NTP_CONFIG_LOCATION_S3/keys"
install_file $CONFIG_NTP_BOOTSTRAP_S3 /etc
install_file $KEY_NTP_BOOTSTRAP_S3 /etc/ntp
sudo sudo /etc/init.d/ntpd stop
sudo sudo /etc/init.d/ntpd start
######################################NTP CONFIG GOES HERE######################################
#Creating user for bulkQueue
sudo adduser -G hadoop -M srev_bqueue
sudo passwd -d srev_bqueue
echo "srev_bqueue ALL=(ALL) NOPASSWD: ALL" > /home/hadoop/srev_bqueue
sudo mv /home/hadoop/srev_bqueue /etc/sudoers.d/
sudo chown root:root /etc/sudoers.d/srev_bqueue
#Creating user for bulkQueue

#installing sshpass 
printf "\n ****** Downloading the rpm to $PWD  *******"
sudo wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -ivh epel-release-6-8.noarch.rpm

printf "\n ****** installing sshpass  *******"
sudo yum --enablerepo=epel -y install sshpass
printf "\n\n **** sshpass installed ******\n\n"

exit 0 # avoid shutdowns

