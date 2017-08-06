#! /bin/bash

touch check.log
exec 1>>/home/hdfs/check.log
exec 2>>/home/hdfs/check.log

EIGHT_SPACE="        ";
CLR_QUOTA="/cmss/bch/bc1.3.4/hadoop/bin/hdfs dfsadmin -clrQuota /user"
CLR_SPACE_QUOTA="/cmss/bch/bc1.3.4/hadoop/bin/hdfs dfsadmin -clrSpaceQuota /user"

#OIFS=$IFS
#IFS="        "
output=`/cmss/bch/bc1.3.4/hadoop/bin/hdfs dfs -count -q /user`
arr=(${output//${EIGHT_SPACE}/ })
quota=${arr[0]}
space_quota=${arr[2]}

echo "quota : $quota"
echo "space quota : $space_quota"

if [ x"$quota" = x"1" ]
then 
    date
    echo $output
    echo "quota is set to 1; clear quota limiting"
    $CLR_QUOTA
fi

if [ "$space_quota"x = "1"x ] 
then
    date
    echo $output
    echo "space quota is set to 1; clear space quota limiting"
    $CLR_SPACE_QUOTA
fi

