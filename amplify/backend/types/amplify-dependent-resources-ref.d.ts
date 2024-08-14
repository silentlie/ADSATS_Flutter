export type AmplifyDependentResourcesAttributes = {
  "api": {
    "AdminQueries": {
      "ApiId": "string",
      "ApiName": "string",
      "RootUrl": "string"
    },
    "adsatsAdminAPI": {
      "ApiId": "string",
      "ApiName": "string",
      "RootUrl": "string"
    },
    "adsatsStaffAPI": {
      "ApiId": "string",
      "ApiName": "string",
      "RootUrl": "string"
    }
  },
  "auth": {
    "adsatsAuth": {
      "AppClientID": "string",
      "AppClientIDWeb": "string",
      "IdentityPoolId": "string",
      "IdentityPoolName": "string",
      "UserPoolArn": "string",
      "UserPoolId": "string",
      "UserPoolName": "string"
    },
    "userPoolGroups": {
      "adminGroupRole": "string"
    }
  },
  "function": {
    "AdminQueries0a0227c1": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    },
    "adsatsAuthPostConfirmation": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    }
  },
  "storage": {
    "adsatsS3": {
      "BucketName": "string",
      "Region": "string"
    }
  }
}