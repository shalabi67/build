package com.build.properties;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;


@Configuration
public class PropertyConfiguration {
    @Value("${me}")
    private String value;

    @PostConstruct
    public String getMyName() {
        return value;
    }
}
