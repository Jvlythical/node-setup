CDE_NODE_NAMESPACE=cde
name=$CDE_NODE_NAMESPACE-ci

docker run -p 8080:8080 -p 50000:50000 --name $name jenkins
