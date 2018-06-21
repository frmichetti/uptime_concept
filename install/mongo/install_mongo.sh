#!/usr/bin/env bash
strip_quotes()
{ 
echo $(echo "$1" | sed -e 's/^"//' -e 's/"$//')
}

create_ec2_instance() 
{
echo $(strip_quotes $(aws ec2 run-instances --image-id ami-3885d854 --security-group-ids sg-32011d54 --count 1 --instance-type t2.large --key-name kuadro-prod --query 'Instances[0].InstanceId'))
}

wait_for_instance_to_be_ready()
{
instance_id=$1
instance_status=""
while [ "$instance_status" != 'ok' ]
do
  echo "Instance still not ready(Status: " $instance_status "). Still waiting..." >&2
  sleep 10
  instance_status=$(strip_quotes $(aws ec2 describe-instance-status --instance-ids $instance_id --query 'InstanceStatuses[0].SystemStatus.Status'))
done
}

create_ec2_instance_and_wait_for_it_to_be_ready()
{
echo "Launching instance..." >&2
instance_id=$( create_ec2_instance )
echo "Instance launched! ID: " $instance_id >&2
echo "Waiting for instance to be ready..." >&2
wait_for_instance_to_be_ready $instance_id
echo "Instance ready!" >&2
echo $instance_id
}

get_instance_public_ip_address()
{
echo $(strip_quotes $(aws ec2 describe-instances --instance-ids $1 --query 'Reservations[0].Instances[0].PublicIpAddress'))
}

install_rvm()
{
  sudo yum install -y curl gpg gcc gcc-c++ make
  sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | sudo bash -s stable
  sudo usermod -a -G rvm `whoami`
  if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
}

install_ruby()
{
  target_ruby='ruby-2.3.5'
  rvm install $target_ruby
  rvm --default use $target_ruby
}

install_mongo()
{	
mongo_version='3.6'
repo_dir='/etc/yum.repos.d'
repo_cfg_path="$repo_dir"'/mongodb-org-'"$mongo_version"'.repo'
base_url_mongo='https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/'"$mongo_version"'/x86_64/'
gpg_key='https://www.mongodb.org/static/pgp/server-'"$mongo_version"'.asc'

sudo mkdir -p $repo_dir
touch '/tmp/mongo.install'
# touch $repo_cfg_path	
cat << EOF > '/tmp/mongo.install'
[mongodb-org-$mongo_version]
name=MongoDB Repository
baseurl=$base_url_mongo
gpgcheck=1
enabled=1
gpgkey=$gpg_key
EOF
sudo mv '/tmp/mongo.install' $repo_cfg_path
sudo yum install -y mongodb-org
sudo service mongod start
}

exec_migration_script()
{
cfg_path=$1
mongo kuadro_log < $cfg_path
}

configure_mongo()
{
schema_target_dir='/home/ec2-user'
schema_file_name="schema.js"
cfg_file_name="mongod.conf"
cfg_dir="/etc"
schema_path="$schema_target_dir"'/'"$schema_file_name"
instance_ip_address=$1
scp -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" $schema_file_name ec2-user@$instance_ip_address:$schema_target_dir
scp -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" $schema_file_name ec2-user@$instance_ip_address:$schema_target_dir
ssh -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" ec2-user@$instance_ip_address "$(typeset -f); exec_migration_script $schema_path"
scp -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" $cfg_file_name ec2-user@$instance_ip_address:/tmp/
ssh -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" ec2-user@$instance_ip_address 'sudo mv /tmp/'"$cfg_file_name"' /etc/'
ssh -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" ec2-user@$instance_ip_address 'sudo service mongod restart'
ssh -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" ec2-user@$instance_ip_address "rm $schema_path"
}


instance_id=$(create_ec2_instance_and_wait_for_it_to_be_ready)
instance_ip_address=$(get_instance_public_ip_address $instance_id)
echo "Instance public ip address:" $instance_ip_address
ssh -i  ~/.ssh/kuadro-prod.pem -o "StrictHostKeyChecking no" ec2-user@$instance_ip_address "$(typeset -f); install_mongo"
configure_mongo $instance_ip_address


