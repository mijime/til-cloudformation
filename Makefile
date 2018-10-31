S3_BUCKET_STACK = TempBucket
S3_BUCKET = $(shell awk '/BucketName/{print$$2}' < outputs/$(S3_BUCKET_STACK).txt)

output-%: deploy-% outputs/%.txt

sudo-output-%: sudo-deploy-% outputs/%.txt

outputs/%.txt: stacks/%.yml
	aws cloudformation describe-stacks \
		--stack-name $* \
		--query 'Stacks[].Outputs[]' \
		--output text > $@

deploy-%: stacks/%.yml
	aws cloudformation deploy \
		--stack-name $* \
		--template-file $<

sudo-deploy-%: stacks/%.yml
	aws cloudformation deploy \
		--stack-name $* \
		--template-file $< \
		--capabilities CAPABILITY_IAM

delete-%: stacks/%.yml
	aws cloudformation delete-stack \
		--stack-name $*

stacks/%.yml: stacks/_%.yml outputs/$(S3_BUCKET_STACK).txt
	aws cloudformation package \
		--s3-bucket $(S3_BUCKET) \
		--template-file $< \
		--output-template-file $@
