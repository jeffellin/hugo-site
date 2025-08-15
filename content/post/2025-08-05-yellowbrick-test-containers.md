+++
title = "Introducing the Yellowbrick TestContainer"
date = 2025-08-15T13:35:15-04:00
tags = ["spring","yellowbrick","tdd" ]
description = "Introducing the Yellowbrick TestContainer"
draft = "false"
codeLineNumbers = true
codeMaxLines = 100
featureImage = "/wp-content/uploads/2025/yb-logo.jpeg"
+++

# Testing with Confidence: Introducing the Yellowbrick Test Container for Spring Boot

In the world of modern software development, integration testing has become crucial for building reliable applications. When your application depends on a specialized database like Yellowbrick, ensuring your tests run against a real database instance becomes even more important. Today, we're excited to introduce the **Yellowbrick Test Container** - a powerful testing tool that brings the full capabilities of Yellowbrick Database directly into your Spring Boot test suite.

## Why Test Containers Matter

### The Problem with Traditional Testing Approaches

Traditionally, developers have faced several challenges when testing database-dependent applications:

1. **In-Memory Database Limitations**: While H2 or similar in-memory databases are fast, they don't replicate the exact behavior, SQL dialect, or performance characteristics of your production database.

2. **Shared Test Environments**: Using a shared test database often leads to test interference, inconsistent state, and the dreaded "works on my machine" syndrome.

3. **Complex Setup**: Installing and maintaining local database instances for each developer and CI environment is time-consuming and error-prone.

4. **Version Mismatches**: Keeping test environments synchronized with production database versions becomes a maintenance nightmare.

### The Test Container Solution

Test containers solve these problems by providing:

- **Real Database Instances**: Your tests run against the actual database you use in production
- **Isolation**: Each test suite gets a fresh, clean database instance
- **Reproducibility**: Consistent behavior across development machines and CI environments
- **Zero Configuration**: No need to install or manage database instances locally
- **Version Control**: Pin exact database versions in your test configuration

### Why Not Just Use PostgreSQL Test Container?

While Yellowbrick is PostgreSQL-compatible and uses the PostgreSQL wire protocol, it's important to understand that **compatibility doesn't mean identical**. Using a PostgreSQL test container as a substitute for Yellowbrick testing is inadvisable for several critical reasons:

**Additional Yellowbrick Features Not in PostgreSQL:**
- **Distribution Strategies**: Yellowbrick's `DISTRIBUTE ON` clause for table distribution across nodes
- **Columnar Storage**: Advanced columnar storage optimizations and compression
- **System Tables**: Yellowbrick-specific system tables like `sys.cluster`, `sys.schema`, `sys.table`
- **Workload Management**: Query routing and resource management features
- **Advanced Analytics**: Specialized functions for time-series and analytical workloads

**Missing PostgreSQL Features in Yellowbrick:**
- **Certain Extensions**: Some PostgreSQL extensions may not be available
- **Advanced Indexing**: Some PostgreSQL index types may not be supported
- **Stored Procedures**: Differences in stored procedure implementations
- **Replication Features**: PostgreSQL-specific replication and streaming features

**Behavioral Differences:**
- **Query Optimization**: Different query planners and execution strategies
- **Data Types**: Subtle differences in data type handling and precision
- **Concurrency**: Different locking and transaction isolation behaviors
- **Performance Characteristics**: Vastly different performance profiles for analytical vs. transactional workloads

Testing against PostgreSQL when your production system uses Yellowbrick creates a false sense of security and can lead to production issues that weren't caught during testing.

## Introducing the Yellowbrick Test Container

The Yellowbrick Test Container extends the popular [Testcontainers](https://testcontainers.org/) framework to support Yellowbrick Database Community Edition. This means you can now run comprehensive integration tests against a real Yellowbrick instance without any manual setup.

### Key Benefits

**🎯 True Compatibility**: While Yellowbrick is PostgreSQL-compatible, it has unique features and limitations that PostgreSQL test containers cannot replicate.

**🚀 Production-Like Testing**: Test against the same database engine, SQL dialect, and features you'll use in production.

**🔧 Zero Configuration**: Start testing immediately without installing Yellowbrick locally.

**🏗️ Spring Boot Integration**: Seamless integration with Spring Boot's testing framework and dependency injection.

**📊 Yellowbrick-Specific Features**: Test distribution strategies, system tables, and other Yellowbrick-specific functionality.

**⚡ Automated Lifecycle**: Container automatically starts before tests and cleans up afterward.

## Setting Up the Yellowbrick Test Container

### Important System Requirements and Limitations

**⚠️ Platform Compatibility Notice**

At this time, the Yellowbrick Test Container has specific system requirements and limitations:

**Supported Platforms:**
- **AMD64 (x86_64) architecture only** - ARM64/Apple Silicon (M1/M2/M3) is not currently supported
- Linux and macOS hosts with AMD64 processors
- Windows with WSL2 and AMD64 processors

**Docker Requirements:**
- **Docker Desktop v4.38.0 or newer**, OR
- **Docker Engine v26.1.3 or newer**
- **Minimum 12GB RAM allocated to Docker** (configure in Docker Desktop settings)
- **Minimum 6 vCPU cores allocated to Docker**

**Database Version:**
- Uses **Yellowbrick Community Edition (yellowbrick-ce)** container image
- May have feature limitations compared to Yellowbrick Enterprise

**Resource Requirements:**
The Yellowbrick database is resource-intensive and requires substantial system resources:
- **Host System**: Recommended 16GB+ total RAM, 8+ CPU cores
- **Docker Allocation**: Must allocate at least 12GB RAM and 6 vCPU to Docker
- **Disk Space**: Several GB for container image and database storage

**Checking Your Docker Configuration:**
```bash
# Check Docker version
docker --version

# Check Docker system info and resource limits
docker system info

# Verify available resources
docker run --rm alpine:latest sh -c 'echo "CPUs: $(nproc), RAM: $(free -h)"'
```

If your system doesn't meet these requirements, the container may fail to start or experience performance issues during tests.

### Prerequisites

Since the Yellowbrick Test Container is not yet available in Maven Central, you'll need to build it locally first.

**Step 1: Clone and Install the Dependency**

```bash
# Clone the repository (URL to be determined)
git clone [TBD_URL]/yellowbrick-testcontainer.git
cd yellowbrick-testcontainer

# Install to your local Maven repository
./mvn install
```

**Step 2: Add Dependency to Your Project**

Add the following dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>com.yellowbrick</groupId>
    <artifactId>yellowbrick-testcontainer</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <scope>test</scope>
</dependency>
```

You'll also need these supporting dependencies:

```xml
<dependencies>
    <!-- Spring Boot Test Starter -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Testcontainers JUnit 5 Support -->
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- PostgreSQL Driver (Yellowbrick uses PostgreSQL protocol) -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- HikariCP Connection Pool -->
    <dependency>
        <groupId>com.zaxxer</groupId>
        <artifactId>HikariCP</artifactId>
    </dependency>
    
    <!-- Spring JDBC -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-jdbc</artifactId>
    </dependency>
</dependencies>
```

## Complete Example: Testing with Yellowbrick

Let's walk through a comprehensive example that demonstrates the power of the Yellowbrick Test Container. This example shows how to test a Spring Boot application with real database operations.

### Test Configuration

```java
@SpringBootTest(
    classes = YellowbrickRepositoryTest.TestConfig.class,
    webEnvironment = SpringBootTest.WebEnvironment.NONE,
    properties = {"spring.profiles.active=test"}
)
@Testcontainers
@Timeout(value = 15, unit = TimeUnit.MINUTES) // Yellowbrick needs time to start
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
class YellowbrickRepositoryTest {

    @Container
    static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
            .withLogConsumer(outputFrame -> 
                System.out.print("[YELLOWBRICK] " + outputFrame.getUtf8String()));

    @SpringBootConfiguration
    static class TestConfig {
        @Bean
        @Primary
        public DataSource dataSource() {
            HikariDataSource dataSource = new HikariDataSource();
            dataSource.setJdbcUrl(yellowbrick.getJdbcUrl());
            dataSource.setUsername(yellowbrick.getUsername());
            dataSource.setPassword(yellowbrick.getPassword());
            dataSource.setDriverClassName("org.postgresql.Driver");
            
            // Conservative settings for test environment
            dataSource.setMaximumPoolSize(5);
            dataSource.setConnectionTimeout(60000);
            dataSource.setValidationTimeout(10000);
            
            return dataSource;
        }

        @Bean
        public JdbcTemplate jdbcTemplate(DataSource dataSource) {
            return new JdbcTemplate(dataSource);
        }
    }

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", yellowbrick::getJdbcUrl);
        registry.add("spring.datasource.username", yellowbrick::getUsername);
        registry.add("spring.datasource.password", yellowbrick::getPassword);
        registry.add("spring.datasource.driver-class-name", yellowbrick::getDriverClassName);
    }
}
```

### Test Setup and Data Preparation

```java
private JdbcTemplate jdbcTemplate;

@BeforeEach
void setUp() {
    // Wait for Yellowbrick to be fully ready
    yellowbrick.waitUntilYellowbrickReady(Duration.ofMinutes(5));
    
    // Create JDBC template
    createJdbcTemplate();
    
    // Set up test data
    setupTestData();
}

private void setupTestData() {
    // Drop existing table if present
    jdbcTemplate.execute("DROP TABLE IF EXISTS test_users CASCADE");

    // Create table with Yellowbrick distribution strategy
    jdbcTemplate.execute("""
        CREATE TABLE test_users (
            id INTEGER,
            name VARCHAR(255),
            email VARCHAR(255),
            age INTEGER
        ) DISTRIBUTE ON (id)
    """);

    // Insert sample data
    jdbcTemplate.update(
        "INSERT INTO test_users (id, name, email, age) VALUES (?, ?, ?, ?)",
        1, "John Doe", "john@example.com", 30
    );
    jdbcTemplate.update(
        "INSERT INTO test_users (id, name, email, age) VALUES (?, ?, ?, ?)",
        2, "Jane Smith", "jane@example.com", 25
    );
}
```

### Test Cases

**Basic Connectivity Test**

```java
@Test
void shouldConnectToYellowbrick() {
    String result = jdbcTemplate.queryForObject("SELECT current_database()", String.class);
    assertThat(result).isNotNull();
    System.out.println("Connected to database: " + result);
}
```

**Yellowbrick-Specific Feature Test**

```java
@Test
void shouldQueryYellowbrickVersion() {
    String version = jdbcTemplate.queryForObject("SELECT version()", String.class);
    assertThat(version).containsIgnoringCase("yellowbrick");
    System.out.println("Yellowbrick version: " + version);
}
```

**Data Operations Test**

```java
@Test
void shouldFindAllUsers() {
    List<Map<String, Object>> users = jdbcTemplate.queryForList(
        "SELECT * FROM test_users ORDER BY name"
    );

    assertThat(users).hasSize(2);
    assertThat(users.get(0).get("name")).isEqualTo("Jane Smith");
    assertThat(users.get(0).get("email")).isEqualTo("jane@example.com");
    assertThat(users.get(0).get("age")).isEqualTo(25);
}

@Test
void shouldInsertNewUser() {
    int rowsAffected = jdbcTemplate.update(
        "INSERT INTO test_users (id, name, email, age) VALUES (?, ?, ?, ?)",
        3, "Alice Johnson", "alice@example.com", 28
    );

    assertThat(rowsAffected).isEqualTo(1);

    Map<String, Object> insertedUser = jdbcTemplate.queryForMap(
        "SELECT * FROM test_users WHERE id = ?", 3
    );
    assertThat(insertedUser.get("name")).isEqualTo("Alice Johnson");
}
```

**System Tables and Metadata Test**

```java
@Test
void shouldExecuteYellowbrickSpecificQueries() {
    // This test would fail with PostgreSQL test container
    // as sys.schema is Yellowbrick-specific
    List<Map<String, Object>> schemas = jdbcTemplate.queryForList(
        "SELECT name FROM sys.schema WHERE name NOT LIKE 'sys%'"
    );

    assertThat(schemas).isNotEmpty();
    System.out.println("Available schemas: " + schemas);
}
```

**Testing Yellowbrick Distribution Strategy**

```java
@Test
void shouldTestDistributionStrategy() {
    // Create table with Yellowbrick-specific DISTRIBUTE ON clause
    // This would fail or be ignored in PostgreSQL
    jdbcTemplate.execute("""
        CREATE TABLE distributed_test (
            id INTEGER,
            data VARCHAR(255)
        ) DISTRIBUTE ON (id)
    """);

    // Verify the distribution strategy was applied
    var result = yellowbrick.executeQuery(
        "SELECT distribution_key FROM sys.table WHERE name = 'distributed_test'"
    );
    
    assertThat(result.getExitCode()).isEqualTo(0);
    assertThat(result.getStdout()).contains("id");
}
```

**Direct ybsql Command Test**

```java
@Test
void shouldTestYellowbrickDistribution() throws Exception {
    var result = yellowbrick.executeQuery("SELECT COUNT(*) FROM test_users");
    
    assertThat(result.getExitCode()).isEqualTo(0);
    System.out.println("ybsql output: " + result.getStdout());
}
```

## Advanced Configuration Options

The Yellowbrick Test Container provides extensive configuration options:

```java
@Container
static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
    .withDatabaseName("testdb")           // Custom database name
    .withUsername("testuser")             // Custom username
    .withPassword("testpass")             // Custom password
    .withBootstrapData("yellowbrick/sql/init.sql")  // Initialize with SQL script
    .withMemory(16)                       // Set memory limit (GB)
    .withCpuCount(8)                      // Set CPU count
    .withDebugMode(true)                  // Enable debug logging
    .withStartupTimeout(20);              // Custom startup timeout (minutes)
```

### Bootstrap Data Initialization

One of the most powerful features of the Yellowbrick Test Container is the ability to automatically initialize your database with custom SQL scripts using the `withBootstrapData()` method. This allows you to set up your database schema, enable features, and insert test data before your tests run.

#### How Bootstrap Initialization Works

The Yellowbrick container includes a sophisticated bootstrap mechanism that executes custom scripts during container startup without requiring image rebuilds. Here's how it works:

**Bootstrap Execution Order:**
1. **Shell Scripts First**: All `*.sh` scripts are executed **in alphabetical order**
2. **SQL Scripts Second**: All `*.sql` files are executed **in alphabetical order**

**Default Bootstrap Location:**
The container automatically looks for bootstrap files in `/mnt/bootstrap/` inside the container.

**Volume Mount Process:**
When you use `withBootstrapData()`, the Testcontainer framework:
1. Copies your classpath resources to the container
2. Mounts them to `/mnt/bootstrap/`
3. The container's entrypoint automatically discovers and executes them

**Naming Strategy for Execution Order:**
Since scripts execute alphabetically, use numeric prefixes to control execution order:

```
/mnt/bootstrap/
├── 01_setup_environment.sh    # Executed first
├── 02_configure_cluster.sh    # Executed second
├── 10_create_database.sql     # Executed after all .sh files
├── 20_create_schema.sql       # Executed after 10_create_database.sql
├── 30_create_tables.sql       # Executed after 20_create_schema.sql
└── 90_insert_data.sql         # Executed last
```

#### Setting Up Bootstrap Scripts

Create your initialization scripts in your test resources directory with proper naming for execution order:

**Example Directory Structure:**
```
src/test/resources/yellowbrick/bootstrap/
├── 01_setup_environment.sh
├── 10_create_database.sql
├── 20_create_schema.sql
├── 30_create_tables.sql
└── 40_insert_data.sql
```

**1. Environment Setup Script (`01_setup_environment.sh`):**
```bash
#!/bin/bash
echo "Setting up Yellowbrick environment..."

# Set environment variables for subsequent SQL scripts
export PGPASSWORD=$YBPASSWORD

# Log current cluster status
echo "Checking cluster status..."
ybsql -c "SELECT state FROM sys.cluster;"

# Verify Yellowbrick is ready
echo "Yellowbrick environment setup complete"
```

**2. Database Creation (`10_create_database.sql`):**
```sql
-- Create UTF8 database for proper character encoding support
CREATE DATABASE test_analytics 
WITH ENCODING 'UTF8' 
LC_COLLATE='en_US.UTF-8' 
LC_CTYPE='en_US.UTF-8';
```

**3. Schema Setup (`20_create_schema.sql`):**
```sql
-- Connect to the new database
\connect test_analytics;

-- Enable JSON features and extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schema for analytics data
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS reporting;

-- Set search path to include our schemas
SET search_path TO analytics, reporting, public;
```

**4. Table Creation (`30_create_tables.sql`):**

**4. Table Creation (`30_create_tables.sql`):**
```sql
-- Create table with JSON support and proper distribution
CREATE TABLE analytics.user_events (
    id UUID DEFAULT uuid_generate_v4(),
    user_id INTEGER NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSON,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_id VARCHAR(100)
) DISTRIBUTE ON (user_id);

-- Create table for aggregated metrics
CREATE TABLE analytics.daily_metrics (
    metric_date DATE NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC(15,2),
    metadata JSON,
    PRIMARY KEY (metric_date, metric_name)
) DISTRIBUTE ON (metric_date);

-- Create reporting view table
CREATE TABLE reporting.user_summary (
    user_id INTEGER PRIMARY KEY,
    total_events INTEGER DEFAULT 0,
    first_seen TIMESTAMP,
    last_seen TIMESTAMP,
    user_tier VARCHAR(20) DEFAULT 'standard'
) DISTRIBUTE ON (user_id);
```

**5. Data Insertion (`40_insert_data.sql`):**
```sql
-- Insert sample test data
INSERT INTO analytics.user_events (user_id, event_type, event_data, session_id) VALUES
(1, 'login', '{"source": "web", "browser": "chrome"}', 'session_001'),
(2, 'purchase', '{"amount": 99.99, "currency": "USD", "items": [{"id": 123, "name": "Product A"}]}', 'session_002'),
(1, 'logout', '{"duration_minutes": 45}', 'session_001'),
(3, 'signup', '{"referral": "google", "plan": "premium"}', 'session_003');

-- Insert sample metrics data
INSERT INTO analytics.daily_metrics (metric_date, metric_name, metric_value, metadata) VALUES
('2024-01-01', 'daily_active_users', 1250, '{"calculation_method": "unique_logins"}'),
('2024-01-01', 'total_revenue', 15000.50, '{"currency": "USD", "includes_tax": true}'),
('2024-01-02', 'daily_active_users', 1380, '{"calculation_method": "unique_logins"}'),
('2024-01-02', 'total_revenue', 18500.75, '{"currency": "USD", "includes_tax": true}');

-- Populate reporting summary
INSERT INTO reporting.user_summary (user_id, total_events, first_seen, last_seen, user_tier)
SELECT 
    user_id,
    COUNT(*) as total_events,
    MIN(timestamp) as first_seen,
    MAX(timestamp) as last_seen,
    CASE 
        WHEN COUNT(*) > 5 THEN 'premium'
        WHEN COUNT(*) > 2 THEN 'standard'
        ELSE 'basic'
    END as user_tier
FROM analytics.user_events
GROUP BY user_id;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON SCHEMA analytics TO ybdadmin;
GRANT ALL PRIVILEGES ON SCHEMA reporting TO ybdadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO ybdadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA reporting TO ybdadmin;
```

#### Configuring the Container with Bootstrap Data

```java
@Container
static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
    .withBootstrapData("yellowbrick/bootstrap/")    // Point to your bootstrap directory
    .withDatabaseName("test_analytics")             // Match the database created in scripts
    .withLogConsumer(outputFrame -> 
        System.out.print("[YELLOWBRICK] " + outputFrame.getUtf8String()));
```

**Alternative: Single File Bootstrap**
```java
@Container
static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
    .withBootstrapData("yellowbrick/sql/init.sql")  // Point to single SQL script
    .withDatabaseName("test_analytics");
```

#### Bootstrap Execution Process

When the container starts, the following happens:

1. **Mount Phase**: Testcontainers copies your classpath resources to `/mnt/bootstrap/` in the container
2. **Discovery Phase**: The container entrypoint scans `/mnt/bootstrap/` for executable files
3. **Shell Execution Phase**: All `*.sh` files are executed in alphabetical order with environment variables available
4. **SQL Execution Phase**: All `*.sql` files are executed in alphabetical order using `ybsql`
5. **Completion**: Container is marked as ready for your tests

**Environment Variables Available in Scripts:**
- `YBUSER`: Database username (default: ybdadmin)
- `YBPASSWORD`: Database password (default: ybdadmin)  
- `YBDATABASE`: Database name (default: yellowbrick)
- `PGPASSWORD`: Set to YBPASSWORD for PostgreSQL tools compatibility

#### Advanced Bootstrap Scenarios

**Conditional Execution in Shell Scripts:**
```bash
#!/bin/bash
# 01_conditional_setup.sh

if [[ "$YB_DEBUG" == "true" ]]; then
    echo "Debug mode enabled - setting up additional logging"
    ybsql -c "ALTER SYSTEM SET log_statement = 'all';"
fi

# Check if specific table exists before creating
TABLE_EXISTS=$(ybsql -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='user_events';" | tr -d ' ')
if [[ "$TABLE_EXISTS" == "0" ]]; then
    echo "Creating user_events table..."
    ybsql -f /mnt/bootstrap/30_create_tables.sql
else
    echo "user_events table already exists, skipping creation"
fi
```

**Error Handling in Bootstrap Scripts:**
```bash
#!/bin/bash
# 02_error_handling.sh

set -e  # Exit on any error

echo "Starting database configuration..."

# Function to handle errors
handle_error() {
    echo "Error occurred in bootstrap script: $1"
    echo "Bootstrap failed at step: $2"
    exit 1
}

# Test database connectivity
ybsql -c "SELECT 1;" || handle_error "Database connectivity test failed" "connectivity_check"

echo "Database bootstrap completed successfully"
```

#### Testing with Bootstrap Data

Now your tests can immediately work with the pre-configured database. The Yellowbrick Test Container provides two distinct approaches for executing queries and validating results:

**1. JDBC Template Approach - Structured Data Access**
The `jdbcTemplate` uses standard JDBC connections and returns structured Java objects (Lists, Maps, etc.). This approach is ideal for data validation and integration with Spring applications:

```java
@Test
void shouldQueryBootstrapJsonData() {
    // jdbcTemplate returns structured data as Java collections
    List<Map<String, Object>> events = jdbcTemplate.queryForList("""
        SELECT user_id, event_type, event_data, timestamp
        FROM analytics.user_events 
        WHERE event_data->>'source' = 'web'
        ORDER BY timestamp
    """);

    // Data is returned as Java objects for easy assertion
    assertThat(events).hasSize(1);
    assertThat(events.get(0).get("event_type")).isEqualTo("login");
    
    // Access JSON data as String for further processing
    String eventData = (String) events.get(0).get("event_data");
    assertThat(eventData).contains("\"browser\": \"chrome\"");
}

@Test
void shouldQueryAggregatedMetrics() {
    // jdbcTemplate handles complex data types like BigDecimal automatically
    List<Map<String, Object>> metrics = jdbcTemplate.queryForList("""
        SELECT metric_date, 
               SUM(CASE WHEN metric_name = 'total_revenue' THEN metric_value ELSE 0 END) as revenue,
               MAX(CASE WHEN metric_name = 'daily_active_users' THEN metric_value ELSE 0 END) as dau
        FROM analytics.daily_metrics
        GROUP BY metric_date
        ORDER BY metric_date
    """);

    assertThat(metrics).hasSize(2);
    
    // Data types are properly converted (BigDecimal, Integer, etc.)
    assertThat(metrics.get(0).get("revenue")).isEqualTo(new BigDecimal("15000.50"));
    assertThat(((Number) metrics.get(0).get("dau")).intValue()).isEqualTo(1250);
}
```

**2. ybsql Command Approach - Text-Based Results**
The `yellowbrick.executeQuery()` method executes commands directly using Yellowbrick's native `ybsql` client and returns raw text output. This approach is useful for testing Yellowbrick-specific features and system-level operations:

```java
@Test
void shouldTestYellowbrickDistributionWithBootstrapData() throws Exception {
    // executeQuery() uses ybsql and returns raw text output
    var result = yellowbrick.executeQuery("""
        SELECT table_name, distribution_key 
        FROM sys.table 
        WHERE schema_name = 'analytics'
        ORDER BY table_name
    """);

    // Check command execution success
    assertThat(result.getExitCode()).isEqualTo(0);
    
    // Parse text output for validation
    String output = result.getStdout();
    assertThat(output).contains("user_events");
    assertThat(output).contains("user_id");
    assertThat(output).contains("daily_metrics");
    assertThat(output).contains("metric_date");
}

@Test
void shouldTestClusterStatus() throws Exception {
    // Use ybsql for Yellowbrick-specific system queries
    var result = yellowbrick.executeQuery("SELECT state FROM sys.cluster;");
    
    assertThat(result.getExitCode()).isEqualTo(0);
    assertThat(result.getStdout()).contains("RUNNING");
    
    // ybsql output includes formatting and headers, unlike JDBC
    System.out.println("Cluster status output:");
    System.out.println(result.getStdout());
}

@Test
void shouldExecuteYellowbrickCommands() throws Exception {
    // Execute administrative commands that may not be available via JDBC
    var result = yellowbrick.executeQuery("SHOW TABLES;");
    
    assertThat(result.getExitCode()).isEqualTo(0);
    
    // Text output requires string-based validation
    String tables = result.getStdout();
    assertThat(tables).containsIgnoringCase("user_events");
    assertThat(tables).containsIgnoringCase("daily_metrics");
}
```

**Key Differences Between the Two Approaches:**

| Aspect | jdbcTemplate | yellowbrick.executeQuery() |
|--------|-------------|---------------------------|
| **Connection Method** | JDBC driver (PostgreSQL protocol) | Native ybsql command |
| **Return Type** | Java objects (List, Map, BigDecimal, etc.) | Raw text string |
| **Data Processing** | Automatic type conversion | Manual string parsing required |
| **Use Case** | Application integration testing | System-level and admin operations |
| **Yellowbrick Features** | Limited to JDBC-compatible features | Full access to Yellowbrick-specific commands |
| **Error Handling** | JDBC exceptions | Exit codes + stderr text |
| **Performance** | Connection pooling available | Command execution overhead |

**When to Use Each Approach:**

**Use `jdbcTemplate` for:**
- Testing application data access logic
- Validating business data and calculations
- Integration with Spring Data/JPA repositories
- Complex data type handling (JSON, NUMERIC, TIMESTAMP)
- Performance-sensitive operations with connection pooling

**Use `yellowbrick.executeQuery()` for:**
- Testing Yellowbrick-specific features (distribution, system tables)
- Administrative operations and cluster management
- Commands not available through JDBC
- Debugging and system diagnostics
- Testing native Yellowbrick SQL extensions

#### Bootstrap Data Best Practices

**1. Use Numeric Prefixes for Execution Order**: 
```
01_setup_environment.sh    # First shell script
02_configure_cluster.sh    # Second shell script  
10_create_database.sql     # First SQL script
20_create_schema.sql       # Second SQL script
30_create_tables.sql       # Third SQL script
90_insert_data.sql         # Last SQL script
```

**2. Handle Encoding in Database Creation**: Always specify UTF8 encoding for proper internationalization support:
```sql
CREATE DATABASE test_db WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';
```

**3. Use Shell Scripts for Environment Setup**: Handle complex logic, conditionals, and environment configuration in `.sh` scripts:
```bash
#!/bin/bash
# Check Yellowbrick readiness before proceeding
while ! ybsql -c "SELECT state FROM sys.cluster;" | grep -q "RUNNING"; do
    echo "Waiting for Yellowbrick cluster to be ready..."
    sleep 5
done
```

**4. Enable Required Features in Separate Scripts**: Include any extensions or features your application needs:
```sql
-- 15_enable_extensions.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "ltree";  -- If supported by Yellowbrick
```

**5. Use Yellowbrick Distribution Strategies**: Always specify distribution strategies for optimal performance:
```sql
CREATE TABLE my_table (...) DISTRIBUTE ON (partition_column);
```

**6. Include Realistic Sample Data**: Provide test data that covers your use cases:
```sql
-- Use meaningful test data that reflects real-world scenarios
INSERT INTO analytics.user_events (user_id, event_type, event_data) VALUES
(1, 'page_view', '{"page": "/dashboard", "referrer": "direct"}'),
(1, 'feature_click', '{"feature": "export_data", "location": "header"}');
```

**7. Set Proper Permissions**: Ensure your test user has necessary permissions:
```sql
GRANT ALL PRIVILEGES ON SCHEMA my_schema TO ybdadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA my_schema TO ybdadmin;
```

**8. Make Scripts Idempotent**: Use IF NOT EXISTS and similar constructs to allow re-running:
```sql
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE TABLE IF NOT EXISTS analytics.events (...);
```

#### Multiple Bootstrap Files Support

You can bootstrap with directory structures containing both shell and SQL scripts:

```java
@Container
static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
    .withBootstrapData("yellowbrick/bootstrap/")  // Point to directory with mixed script types
    .withDatabaseName("test_analytics");
```

**Recommended Directory Structure:**
```
src/test/resources/yellowbrick/bootstrap/
├── 01_setup_environment.sh      # Environment and cluster validation
├── 02_configure_yellowbrick.sh  # Yellowbrick-specific configuration  
├── 10_create_database.sql       # Database creation
├── 20_create_schema.sql         # Schema and extension setup
├── 30_create_tables.sql         # Table definitions with distribution
├── 40_create_views.sql          # Views and computed tables
├── 50_create_functions.sql      # Custom functions (if supported)
└── 90_insert_data.sql           # Sample data insertion
```

**Execution Flow:**
1. `01_setup_environment.sh` → `02_configure_yellowbrick.sh` (all .sh files alphabetically)
2. `10_create_database.sql` → `20_create_schema.sql` → `30_create_tables.sql` → `40_create_views.sql` → `50_create_functions.sql` → `90_insert_data.sql` (all .sql files alphabetically)

The bootstrap data feature ensures your tests start with a fully configured Yellowbrick environment, including UTF8 support, JSON capabilities, and realistic test data that matches your production schema. The combination of shell scripts for environment setup and SQL scripts for database structure provides maximum flexibility for complex initialization scenarios.

## Best Practices

### Performance Optimization

1. **Use Static Containers**: Share container instances across test methods using `static` to avoid restart overhead.

2. **Set Appropriate Timeouts**: Yellowbrick requires extended startup time, so configure generous timeouts.

3. **Resource Allocation**: Allocate sufficient memory and CPU for optimal performance.

### Test Isolation

1. **Clean Data Between Tests**: Use `@DirtiesContext` or manual cleanup to ensure test isolation.

2. **Transaction Rollback**: Consider using `@Transactional` with rollback for faster cleanup.

### CI/CD Integration

1. **Docker Requirements**: Ensure your CI environment supports Docker and privileged containers.

2. **Resource Limits**: Configure appropriate memory and CPU limits for CI environments.

3. **Parallel Execution**: Be cautious with parallel test execution due to resource requirements.

## Troubleshooting Common Issues

### Container Startup Issues

```java
// Add comprehensive logging
@Container
static YellowbrickContainer yellowbrick = YellowbrickContainer.create()
    .withLogConsumer(outputFrame -> 
        System.out.print("[YELLOWBRICK] " + outputFrame.getUtf8String()))
    .withStartupTimeout(Duration.ofMinutes(20));
```

### Connection Problems

```java
private void testConnectionWithRetry(JdbcTemplate jdbcTemplate, int maxRetries) {
    for (int i = 0; i < maxRetries; i++) {
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return;
        } catch (Exception e) {
            if (i == maxRetries - 1) {
                throw new RuntimeException("Failed to connect after " + maxRetries + " attempts", e);
            }
            
            try {
                Thread.sleep(10000); // Wait 10 seconds between attempts
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Interrupted during connection retry", ie);
            }
        }
    }
}
```

## Test-Driven Development with CI/CD Integration

The Yellowbrick Test Container truly shines when integrated into a comprehensive Test-Driven Development (TDD) workflow within your CI/CD pipeline. The following diagram illustrates how the container facilitates confidence from development through production deployment:

![Anatomy of a Rule](/wp-content/uploads/2025/cicd_tdd_workflow_diagram.svg)

### The Complete TDD Workflow

**Development Environment (Local TDD Cycle)**

The development process begins with the classic TDD cycle—Red, Green, Refactor—but with a crucial difference: instead of testing against mock databases or PostgreSQL substitutes, developers write failing tests against a real Yellowbrick instance running locally via the test container.

```java
// Red: Write a failing test for Yellowbrick-specific functionality
@Test
void shouldDistributeDataCorrectly() {
    // This test initially fails - no table exists yet
    jdbcTemplate.execute("""
        CREATE TABLE user_analytics (
            user_id INTEGER,
            event_count INTEGER,
            last_activity TIMESTAMP
        ) DISTRIBUTE ON (user_id)
    """);
    
    // Test will fail until implementation is complete
    var result = yellowbrick.executeQuery(
        "SELECT distribution_key FROM sys.table WHERE table_name = 'user_analytics'"
    );
    assertThat(result.getStdout()).contains("user_id");
}
```

**Green Phase**: Developers implement the minimal code to make the test pass, knowing their solution works with actual Yellowbrick distribution strategies, JSON handling, and system tables.

**Refactor Phase**: Code improvements are validated against the real database, ensuring optimizations don't break Yellowbrick-specific functionality.

**CI/CD Pipeline Integration**

When developers push code, the CI/CD pipeline automatically:

1. **Builds and Compiles**: Standard Maven/Gradle build process
2. **Runs Unit Tests**: Fast, isolated tests for business logic
3. **Executes Integration Tests**: **The critical phase** where Yellowbrick Test Container spins up a real database instance
4. **Validates Production Readiness**: Security scans and quality checks
5. **Packages and Deploys**: Creates artifacts ready for production

**The Test Container Advantage in CI**

In the CI environment, the test container provides the same benefits as local development:

```yaml
# GitHub Actions example
name: CI Pipeline
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
    - name: Run Integration Tests
      run: mvn test
      env:
        # Test container automatically handles Yellowbrick setup
        TESTCONTAINERS_CHECKS_DISABLE: true
```

The container automatically:
- Pulls the Yellowbrick Community Edition image
- Starts a real database cluster
- Executes bootstrap scripts for schema setup
- Runs all integration tests against actual Yellowbrick features
- Cleans up resources after test completion

**Production Confidence**

By the time code reaches production, teams have **high confidence** because:

- **Distribution Strategies** have been tested against real Yellowbrick partitioning
- **JSON Operations** have been validated with actual Yellowbrick JSON support
- **System Table Queries** have been verified against real `sys.*` tables
- **SQL Compatibility** has been proven with the actual Yellowbrick SQL engine
- **Performance Characteristics** are understood from container testing

### Key Benefits of This Workflow

**🔄 Continuous Validation**: Every code change is validated against real Yellowbrick functionality, not approximations.

**⚡ Fast Feedback**: Developers get immediate feedback about Yellowbrick compatibility without needing to deploy to staging environments.

**🛡️ Risk Reduction**: Production deployments have significantly lower risk because database-specific features have been thoroughly tested.

**📈 Velocity Increase**: Teams can move faster knowing their tests provide accurate validation of production behavior.

**🎯 Feature Confidence**: New features using advanced Yellowbrick capabilities (analytics functions, distribution strategies, JSON operations) are tested from day one.

This integrated approach transforms database testing from a deployment-time concern into a development-time advantage, enabling teams to build robust applications with confidence in their Yellowbrick integration.

## Conclusion

The Yellowbrick Test Container represents a significant step forward in integration testing for applications using Yellowbrick Database. By providing a real database instance in your test environment, you can:

- **Test with Confidence**: Verify your application works with actual Yellowbrick features and behavior
- **Catch Issues Early**: Identify database-specific problems before they reach production
- **Simplify Development**: Eliminate the need for complex local database setups
- **Improve CI/CD**: Create reliable, reproducible test pipelines

Whether you're building analytics applications, data warehouses, or any system that relies on Yellowbrick's powerful capabilities, the Yellowbrick Test Container provides the foundation for robust, reliable testing.

Ready to get started? Clone the repository, install the dependency, and begin testing with confidence today!

---

*The Yellowbrick Test Container is actively developed by the Yellowbrick Spring AI Team. For questions, issues, or contributions, please refer to the project repository.*