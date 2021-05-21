# after install docker add user (marco in this case)
# give all users permission to run the docker sock
sudo chmod 666 /var/run/docker.sock

# pull official ubuntu image
docker pull ubuntu

# list containers and the time they were used
docker ps  -a

# start up a bash
docker run -it ubuntu bash

#docker run ubuntu bash -c "apt-get -y update" 
#docker run -it ubuntu bash

docker run -it ubuntu bash
apt install nginx

# docker image is something immutable, like a template a virtual environment. what you do is that you build a container on top of the image to run applications. a layer is written on top of the image, it's writeable, it is possible to install stuff etc. Explanation here: https://phoenixnap.com/kb/docker-image-vs-container

# remove all containers
docker container rm $(docker container ls -aq)
docker container rm de9034929c41


# start container interactively (once created)
docker start -ai ae106acb4599 
docker rename brave_thompson marco_g

# new container
docker run -it ubuntu bash
docker rename nifty_mendel marco_g12


docker start marco_g

##################################
# Step 1: pull official ubuntu image
###################################

docker pull ubuntu

############################
# Step 2: create new 
# containers with a shared 
# directory between containers
# and host
############################

# create container and share directory with host system (marco.girardello@gmail.com)
docker run -it --name marco_g -v /home/marco/dockerdata:/home/scripts ubuntu
# create container and share directory with host system (marco.girardello12@gmail.com)
docker run -it --name marco_g12 -v /home/marco/dockerdata:/home/scripts ubuntu
# create container and share directory with host system (curruspito.papilio@gmail.com)
docker run -it --name papilio -v /home/marco/dockerdata:/home/scripts ubuntu
# create container and share directory with host system (simone.ruzza12@gmail.com)
docker run -it --name dawn -v /home/marco/dockerdata:/home/scripts ubuntu
# create container and share directory with host system (curruspito.papilio1@gmail.com)
docker run -it --name dusk -v /home/marco/dockerdata:/home/scripts ubuntu
# create container and share directory with host system (adharapv@gmail.com)
docker run -it --name roller -v /home/marco/dockerdata:/home/scripts ubuntu



###############################
# Step 3: set up GEE Python API
###############################

# within each docker environment: authentication needs to be 
# via a browser using the URL produced during the earthengine authenticate
#docker start -ai 23780635557e
apt update
apt install python3
apt-get install python3-pip
pip3 install ee
pip3 install earthengine-api
pip3 install pandas
earthengine authenticate 

####################################################
# Step 4: start all the containers (non-interactively)
####################################################
for i in $(docker container ls -aq);do
   docker start $i
done


docker start -ai dawn


#########################################################
# Step 5: copy GEE code to shared folder (Guido's script)
#######################################################

#cp /mnt/data1tb/Dropbox/phenology/scripts/phenodiv.py /home/marco/dockerdata/


####################################################
# Step 6: run script and save results to gcloud 
# phenology project
####################################################
  
# pass year and  tile numbers 
# docker exec --env year=2002 --env minpoly=1 --env maxpoly=506 marco_g bash -c "python3 /home/scripts/phenodiv.py"
# pass environment year environment variable
# docker exec --env year=2002 --env minpoly=507 --env maxpoly=1013 marco_g12 bash -c "python3 /home/scripts/phenodiv.py"
# pass environment year environment variable
# docker exec --env year=2002 --env minpoly=1014 --env maxpoly=1520 papilio bash -c "python3 /home/scripts/phenodiv.py"
# pass environment year environment variable
# docker exec --env year=2002 --env minpoly=1521 --env maxpoly=2026 dawn bash -c "python3 /home/scripts/phenodiv.py"

# pass environment year environment variable
#docker exec --env year=2002 --env minpoly=1521 --env maxpoly=2026 dawn bash -c "python3 /home/scripts/phenodiv.py"


# delete running tasks
#docker exec marco_g /bin/bash -c "sh /home/scripts/deletetasks.sh"
# docker exec marco_g /bin/bash -c "sh /home/scripts/deletetasks.sh"
# docker exec papilio /bin/bash -c "sh /home/scripts/deletetasks.sh"
# docker exec dawn /bin/bash -c "sh /home/scripts/deletetasks.sh"

# --- use script with minimum
# pass year and  tile numbers 
docker exec --env year=2003 --env minpoly=1 --env maxpoly=506 marco_g bash -c "python3 /home/scripts/8daymetric_tempfilt.py"

# pass environment year environment variable
docker exec --env year=2003 --env minpoly=507 --env maxpoly=1013 marco_g12 bash -c "python3 /home/scripts/8daymetric_tempfilt.py"


# pass environment year environment variable
docker exec --env year=2003 --env minpoly=1014 --env maxpoly=1520 papilio bash -c "python3 /home/scripts/8daymetric_tempfilt.py"
# last batch split between three different accounts
# pass environment year environment variable
docker exec --env year=2003 --env minpoly=1521 --env maxpoly=1689 dawn bash -c "python3 /home/scripts/8daymetric_tempfilt.py"
docker exec --env year=2003 --env minpoly=1690 --env maxpoly=1858 dusk bash -c "python3 /home/scripts/8daymetric_tempfilt.py"
docker exec --env year=2003 --env minpoly=1859 --env maxpoly=2039 roller bash -c "python3 /home/scripts/8daymetric_tempfilt.py"






# fix 2003
#docker exec --env year=2003 --env minpoly=2027 --env maxpoly=2039 marco_g bash -c "python3 /home/scripts/phenodiv_zeroversion.py"


#docker exec --env year=2002 --env minpoly=1530 --env maxpoly=1531 dawn bash -c "python3 /home/scripts/phenodiv_zeroversion.py"

#docker exec --env year=2002 --env minpoly=1 --env maxpoly=9 marco_g bash -c "python3 /home/scripts/phenodiv_zeroversion_splitgrid.py"


# finishes year 2002 
#docker exec --env year=2002 --env minpoly=0 --env maxpoly=34 marco_g bash -c "python3 /home/scripts/phenodiv_zeroversion.py"
# pass environment year environment variable
#docker exec --env year=2002 --env minpoly=35 --env maxpoly=68 marco_g12 bash -c "python3 /home/scripts/phenodiv_zeroversion.py"
# pass environment year environment variable
#docker exec --env year=2002 --env minpoly=69 --env maxpoly=102 papilio bash -c "python3 /home/scripts/phenodiv_zeroversion.py"
# pass environment year environment variable
#docker exec --env year=2002 --env minpoly=103 --env maxpoly=137 dawn bash -c "python3 /home/scripts/phenodiv_zeroversion.py"
# pass environment year environment variable
#docker exec --env year=2002 --env minpoly=138 --env maxpoly=172 marco_g bash -c "python3 /home/scripts/phenodiv_zeroversion.py"

# get info for tasks


# pass year and  tile numbers 
docker exec --env year=2003 --env minpoly=1 --env maxpoly=506 marco_g bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"

# pass environment year environment variable
docker exec --env year=2003 --env minpoly=507 --env maxpoly=1013 marco_g12 bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"


# pass environment year environment variable
docker exec --env year=2003 --env minpoly=1014 --env maxpoly=1520 papilio bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# last batch split between three different accounts
# pass environment year environment variable
docker exec --env year=2003 --env minpoly=1521 --env maxpoly=1689 dawn bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
docker exec --env year=2003 --env minpoly=1690 --env maxpoly=1858 dusk bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
docker exec --env year=2003 --env minpoly=1859 --env maxpoly=2039 roller bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"


# North america

#docker exec --env year=2003 --env minpoly=1 --env maxpoly=16 marco_g bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"


# pass environment year environment variable
#docker exec --env year=2003 --env minpoly=1 --env maxpoly=5 marco_g12 bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# pass environment year environment variable
#docker exec --env year=2003 --env minpoly=6 --env maxpoly=11 papilio bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# last batch split between three different accounts
# pass environment year environment variable
#docker exec --env year=2003 --env minpoly=12 --env maxpoly=18 dawn bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
#docker exec --env year=2003 --env minpoly=19 --env maxpoly=25 dusk bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
#docker exec --env year=2003 --env minpoly=26 --env maxpoly=27 roller bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"



# pass year and  tile numbers 
docker exec --env year=2003 --env minpoly=2040 --env maxpoly=2043 marco_g bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# pass environment year environment variable
docker exec --env year=2003 --env minpoly=2044 --env maxpoly=2047 marco_g12 bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# pass environment year environment variable
docker exec --env year=2003 --env minpoly=2048 --env maxpoly=2052 papilio bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
# last batch split between three different accounts
# pass environment year environment variable
docker exec --env year=2003 --env minpoly=2053 --env maxpoly=2056 dawn bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
docker exec --env year=2003 --env minpoly=2057 --env maxpoly=2061 dusk bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"
docker exec --env year=2003 --env minpoly=2062 --env maxpoly=2065 roller bash -c "python3 /home/scripts/8daymetric_terraclimate_test.py"




