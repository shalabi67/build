# Property using another property
This will demo how a property can use another property in spring boot.

## Run
- mvn spring-boot:run
- in the log you should see `c.b.properties.PropertyConfiguration     : value=I am Mohammad`

### using environment variable
- mvn spring-boot:run -Dspring-boot.run.arguments=--prop3=Shalabi
- in the log you should see `c.b.properties.PropertyConfiguration     : value=I am Shalabi`