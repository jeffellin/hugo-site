+++
title = "Using JNDI with Emedded Tomcat"
date = 2020-07-02T00:35:15-04:00
tags = ["spring","tomcat"]
featured_image = ""
description = "Using JNDI with Emedded Tomcat"
draft = "false"
+++

# Using JNDI with Emedded Tomcat

Recently I was working on a project where we were migrating an application off of WebSphere and onto Spring Boot. This application used JNDI to store configuration in JNDI.  While we were ultimately planning to extract this configuration using Spring Cloud Config Server I felt it worthwhile to udnerstand how Tomcat works with JNDI.

## Spring Boot and Embedded Tomcat

Spring Boot by default uses Tomcat as its web container.  During apaplication startup it initializes a pretty bare bones Tomcat instance.  The framework does provide a few hook points in order to customize the configuartion. 

If this were standard XML based configuration you would add your environment configuration to the `context.xml` as follows:

		
```xml
<Context ...>
  ...
  <Environment name="maxExemptions" value="10"
         type="java.lang.Integer" override="false"/>
  ...
</Context>
```

Since we are planning to do Spring Java configration we must make the following two changes in an `@Configuration` class.

The two changes we ned to make are.

1. Enable Naming.  Embedded Tomcat by default does not have naming enabled.
2. Add Name vaule Pairs to the context.

Spring Boot provides an out of the box bean called a  `ServletWebServerFactory`. We will be using this class to customize our application.

```java
@Bean
public ServletWebServerFactory webServerFactory() {
	TomcatServletWebServerFactory factory = new TomcatServletWebServerFactory(){
		@Override
		protected TomcatWebServer getTomcatWebServer(Tomcat tomcat) {
			//naming is not enabled by default
			tomcat.enableNaming();
			return new TomcatWebServer(tomcat, this.getPort() >= 0, this.getShutdown());
		}
	};
	factory.addContextCustomizers(new TomcatContextCustomizer() {
		@Override
		public void customize(Context context) {
			//add a Context Environment for each value.
			ContextEnvironment ce = new ContextEnvironment();
			ce.setName("maxExemptions");
			ce.setValue("1234");
			ce.setType("java.lang.String");
			context.getNamingResources().addEnvironment(ce);
			}
		});
		return factory;
	}
```

We could grab our context values easily using `@Value` annotations that we inject via the standard Spring configuration mechanisms.

## Reading the Config

Now that we have a new JNDI entry called `foo` we need some code to read that property.

The following code illustrates how to read the property in a Struts Action class.

```java
public ActionForward execute(ActionMapping mapping,ActionForm form,
			HttpServletRequest request,HttpServletResponse response) throws Exception {

		JndiTemplate jndiTemplate = new JndiTemplate();

		String foo = (String)jndiTemplate.lookup("java:/comp/env/maxExemptions");

		HelloWorldForm helloWorldForm = (HelloWorldForm) form;
		helloWorldForm.setMessage("Hello World! Struts: "+foo);
		
		return mapping.findForward("success");
	}
```

One thing that was problematic for us is that Embedded Tomcat puts all naming resources into `java:comp/env/` This meant we still had to make some changes to the original code running on WebSphere since it didn't assume this location. 

Readig StackOverflow it seems it may be possible to customize this behavior by implementing our own `InitialContextFactory` but if we go down that route we would still need to change the library doing lookups so I'd rather just externalize the JNDI strings so they can be changed depending on if the application is running on Tomcat or WebSphere

Leave a comment below if you have any ideas on how to avoid needing to prepend lookup Strings with `java:/comp/env`

