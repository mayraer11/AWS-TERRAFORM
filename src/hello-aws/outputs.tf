#Variable de Salida que obtendra la URL del API REST
output "base_url" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.invoke_url}/${var.last_path_segment}"
}