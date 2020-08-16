 /**
 * Registers a DataSource as a JNDI lookup (opposed to any other method of DataSource defining Spring boot offers).
 * Used for consistency since JNDI is usually configured for DataSources in a standalone Tomcat.
 */
@Bean(destroyMethod = "")
@Profile("!test")
public DataSource jndiDataSource() throws NamingException {
    JndiObjectFactoryBean jndiFactoryBean = new JndiObjectFactoryBean();
    jndiFactoryBean.setJndiName("java:comp/env/" + jndiName);
    jndiFactoryBean.setProxyInterface(DataSource.class);
    jndiFactoryBean.setLookupOnStartup(true);
    jndiFactoryBean.afterPropertiesSet();
    return (DataSource) jndiFactoryBean.getObject();
}



ublic TomcatEmbeddedServletContainerFactory tomcatEmbeddedServletContainerFactory() {
    return new TomcatEmbeddedServletContainerFactory() {

        @Override
        protected TomcatEmbeddedServletContainer getTomcatEmbeddedServletContainer(Tomcat tomcat) {
            tomcat.enableNaming();
            return super.getTomcatEmbeddedServletContainer(tomcat);
        }

        @Override
        protected void postProcessContext(Context context) {
            ContextResource contextResource = new ContextResource();
            contextResource.setName(jndiName);
            contextResource.setAuth("Container");
            contextResource.setType("javax.sql.DataSource");
            contextResource.setProperty("url", url);
            contextResource.setProperty("username", username);
            contextResource.setProperty("password", password);
            contextResource.setProperty("initialSize", initialSize);
            contextResource.setProperty("maxWaitMillis", maxWait);
            contextResource.setProperty("maxTotal", maxActive);
            contextResource.setProperty("maxIdle", maxIdle);
            contextResource.setProperty("maxAge", maxAge);
            contextResource.setProperty("testOnBorrow", testOnBorrow);
            contextResource.setProperty("validationQuery", validationQuery);
            context.getNamingResources().addResource(contextResource);

        }
    }
}