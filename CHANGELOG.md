## 1.0.0 (Agosto 14, 2019)

FEATURES:

* **New Resource:** `aws_s3_bucket`
* **New Resource:** `aws_s3_bucket_object`
* **New Resource:** `aws_iam_role`
* **New Resource:** `aws_lambda_function`
* **New Resource:** `aws_api_gateway_rest_api`
* **New Resource:** `aws_api_gateway_resource`
* **New Resource:** `aws_api_gateway_method`
* **New Resource:** `aws_api_gateway_integration`
* **New Resource:** `aws_api_gateway_deployment`

IMPROVEMENTS:

* resource/api_gateway_integration: Add `integration_http_method` POST (las funciones lambdas solo pueden ser invocadas por POST)

* resource/api_gateway_integration: Add `type` AWS_PROXY (para integración de proxy Lambda)
