+++
title = "Spring CXF"
date = 2020-07-02T00:35:15-04:00
tags = ["spring","cxf"]
category = ["tech"]
featured_image = ""
description = "Spring CXF"
draft = "false"
+++

## Enabling Logging of in/out messages 

```java
@Bean
public AbstractLoggingInterceptor logOutInterceptor() {
    LoggingOutInterceptor logOutInterceptor = new LoggingOutInterceptor();
    logOutInterceptor.setPrettyLogging(true);
    return logOutInterceptor;
}

@Bean
public AbstractLoggingInterceptor logInInterceptor() {
    LoggingInInterceptor logOutInterceptor = new LoggingInInterceptor();
    logOutInterceptor.setPrettyLogging(true);
    return logOutInterceptor;
}

@Bean(name = Bus.DEFAULT_BUS_ID)
public SpringBus springBus() {
    SpringBus springBus = new SpringBus();
    springBus.getInFaultInterceptors().add(logOutInterceptor());
    springBus.getInInterceptors().add(logInInterceptor());
    springBus.getOutInterceptors().add(logOutInterceptor());
    springBus.getOutFaultInterceptors().add(logOutInterceptor());
    return springBus;
}
```

## Maven plugin

```xml
<plugin>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-codegen-plugin</artifactId>
    <version>3.3.7</version>
    <executions>
        <execution>
            <id>generate-sources</id>
            <phase>generate-sources</phase>
            <configuration>
                <sourceRoot>${project.build.directory}/generated-sources/cxf</sourceRoot>
                <wsdlOptions>
                    <wsdlOption>
                        <wsdl>${basedir}/src/main/resources/myService.wsdl</wsdl>
                        <wsdlLocation>classpath:myService.wsdl</wsdlLocation>
                    </wsdlOption>
                </wsdlOptions>
            </configuration>
            <goals>
                <goal>wsdl2java</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## Maven dependencies

Minimal tested set.  

```xml
 <dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-frontend-jaxws</artifactId>
    <version>3.3.7</version>
</dependency>

<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-transports-http</artifactId>
    <version>3.3.7</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web-services</artifactId>
</dependency>
```