STACK_NAME := redmine
REGION := us-east-1

include .secrets

update-stack:
	cftool -r $(REGION) create \
		-p KeyName=webhost1 -p InstanceType=t3.small \
		-p -p SESUsername=$(SESUsername) -p SESPassword=$(SESPassword) \
		-p Subnet=subnet-4acaf100 \
		-p EmailDomain=cloudonix.io \
		-p CertificateId=$(CertARN) \
		cloud-formation.yaml $(STACK_NAME)
