#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0653444S9M5BRWXUG0B" 
DOMAIN_NAME="lohithadev.online"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"
B="\e[34m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d +%H:%M:%S")
#shell roboshop

if [ $# -lt 2 ]; then
    echo -e " $TIMESTAMP :: $R[ERROR]:Atleast 2 arguments required $N"
    echo "USAGE :$0 [create /delete] [instance1] [instance2...]"
    exit 1
fi

Action=$1
shift  # Shift the arguments to remove the first argument (action) from the list
if [ "$Action" != "create" ] && [ "$Action" != "delete" ]; then
    echo -e "$TIMESTAMP :: $R[ERROR] : First argument must be either 'create' or 'delete' $N"
    echo "USAGE :$0 [create /delete] [instance1] [instance2...]"
    exit 1
fi

get_instance_id() {
    name=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=roboshop-$name"  "Name=instance-state-name,
    Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text
}

for instance in $@
do 
   INSTANCE_ID=$(get_instance_id $instance)
    if [ "$Action" == "create" ]; then
        if [ "$INSTANCE_ID" == "None" ]; then
            echo -e "$TIMESTAMP:: $G Launching instance:roboshop-$instance $N"
            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id $AMI_ID \
                --instance-type t3.micro \
                --security-groups "roboshop-common" "roboshop-$instance" \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
                )
                echo "Instance ID: $INSTANCE_ID"
        else
            echo -e "$TIMESTAMP:: $Y roboshop-$instance already running with Instance ID: $INSTANCE_ID $N"
        fi
        if [ $instance == "frontend" ]; then
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text
        )
             R53_RECORD="$DOMAIN_NAME"
       else
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text
            )
            R53_RECORD="$instance.$DOMAIN_NAME"
        fi
        
        #### Updating R53 Record ####
        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
            {
                "Comment": "Update A record to new IP",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": "'$R53_RECORD'",
                            "Type": "A",
                            "TTL": 1,
                            "ResourceRecords": [
                                {
                                    "Value": "'$IP'"
                                }
                            ]
                        }
                    }
                ]
            }
        '
        echo "updated R53 record for - roboshop-$instance"
    else
      if [ "$INSTANCE_ID" == "None" ]; then
        echo -e "$TIMESTAMP:: $P roboshop-$instance is already destroyed or not running $N"
      else
         aws ec2 terminate-instances --instance-ids $INSTANCE_ID
            echo -e "$TIMESTAMP:: $G roboshop-$instance is destroyed $N"
      fi
    fi
         

done
        