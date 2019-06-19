# Build images for the three containers that the app is base of

# docker build -t javigzz/udemy-multi-client -f ./client/Dockerfile ./client
# docker build -t javigzz/udemy-multi-server -f ./server/Dockerfile ./server
# docker build -t javigzz/udemy-multi-worker -f ./worker/Dockerfile ./worker

# but, this will just be seen by the cluster as applying "latest" images again, so no changes will be seen
# by kubernetes, so no deployment will take place
# in order to avoid it we add the commit hash ($GIT_SHA) as tag to ensure change

docker build -t javigzz/udemy-multi-client:latest -t javigzz/udemy-multi-client:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t javigzz/udemy-multi-server:latest -t javigzz/udemy-multi-server:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t javigzz/udemy-multi-worker:latest -t javigzz/udemy-multi-worker:$GIT_SHA -f ./worker/Dockerfile ./worker

# Push images to the docker hub repository. The image names must match the ones in the *-deployment.yaml!!
docker push javigzz/udemy-multi-client:latest
docker push javigzz/udemy-multi-client:$GIT_SHA

docker push javigzz/udemy-multi-server:latest
docker push javigzz/udemy-multi-server:$GIT_SHA

docker push javigzz/udemy-multi-worker:latest
docker push javigzz/udemy-multi-worker:$GIT_SHA


# since kubectl is already associated to the cluster in google cloud, this command will apply
# all the .yaml k8s config files (deployments, services, ingress..) in that cluster
kubectl apply -f k8s

# Imperative set the container images of the pods inside the three deployments
# set the images with the hash to ensure that kubernetes notices the change (it is not just "latest")
kubectl set image deployment/client-deployment client=javigzz/udemy-multi-client:$GIT_SHA
kubectl set image deployment/worker-deployment worker=javigzz/udemy-multi-worker:$GIT_SHA
kubectl set image deployment/server-deployment server=javigzz/udemy-multi-server:$GIT_SHA

