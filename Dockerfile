FROM openjdk:8
ADD jarstaging/com/valaxy/demo-workshop/2.1.2/demo-workshop-2.1.2.jar Samtrend.jar
ENTRYPOINT [ "java", "-jar", "Samtrend.jar" ]
