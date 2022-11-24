# Create the IAM role/profile for the API Call
resource "aws_iam_instance_profile" "APICall_profile" {
  name = "${var.prefix}-fgcp-APICall_profile"
  role = aws_iam_role.APICallrole.name
}

resource "aws_iam_role" "APICallrole" {
  name = "${var.prefix}-fgcp-APICall_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "APICallpolicy" {
  name        = "${var.prefix}-fgcp-APICall_policy"
  path        = "/"
  description = "Policies for the FGT APICall Role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Action": 
            [
              "ec2:Describe*",
              "ec2:AssociateAddress",
              "ec2:AssignPrivateIpAddresses",
              "ec2:UnassignPrivateIpAddresses",
              "ec2:ReplaceRoute",
              "eks:ListClusters"
            ],
            "Resource": "*"
        }
      ]
}
EOF
}

resource "aws_iam_policy_attachment" "APICall-attach" {
  name       = "${var.prefix}-fgcp-APICall-attachment"
  roles      = [aws_iam_role.APICallrole.name]
  policy_arn = aws_iam_policy.APICallpolicy.arn
}