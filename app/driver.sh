# Export ENV variables
export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)

# $1 is the number of nodes.
# $2 is the fully qualified docker image name of the cde-node
# In migrating, it is passed by the migrate.sh script.
sh ./start-node-pro.sh $1 $2
