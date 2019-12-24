# packer
=========

Packer for creating identical machine images for multiple platforms from a single JSON configuration.

Requirements
------------
```
Packer
```

Variables
--------------
We can use -var or -var-file flags to define the values of the variables using command-line.
```
region is AWS account region where we want to bake the AMI
vpc_id is the vpc id of the AWS account used by packer.
subnet_id is subnet, where packer will launch the instance.
source_ami is the base AMI used by packer.
```

Example
----------------
To validate the packer template
```
packer validate -var \
> 'region=ap-south-1' \
> -var 'vpc_id=vpc-XXXXXXXXXX' \
> -var 'subnet_id=subnet-XXXXXXXXXXXX' \
> -var 'source_ami=ami-XXXXXXXXXXX' \
> packer_ebssurrogate.json
```
To build the AMI
```
packer build -debug \
> -var 'region=ap-south-1' \
> -var 'vpc_id=vpc-XXXXXXXXXX' \
> -var 'subnet_id=subnet-XXXXXXXXXXXX' \
> -var 'source_ami=ami-XXXXXXXXXXX' \
> packer_ebssurrogate.json
```
## Documentation

Comprehensive documentation is viewable on the Packer website:

https://www.packer.io/docs

Author Information
------------------


* **Open DevOps Automation** - *work* - [github](https://github.com/opendevopsautomation)
