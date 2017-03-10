# Export ENV variables
export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../env.yml)

sh ./start-node-pro.sh $1
