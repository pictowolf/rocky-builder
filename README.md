### Rocky 8 automated builder
This is an automated way to build a Rocky Linux image to allow for a continually updated base image.

## Requirements
* Packer
* Hyper-V

## todo
* add vmware-iso source
* move ansible install out of post kickstart?

## How to use
* Change dev.pkvars.hcl.example to dev.pkvars.hcl and ammend the values as needed. Use this to control different environments, EG: staging, prod etc.
* packer build -var-file="dev.pkvars.hcl" .\packer\.