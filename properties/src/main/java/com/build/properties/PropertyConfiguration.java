package com.build.properties;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;

@Slf4j
@Configuration
public class PropertyConfiguration {
    @Value("${me}")
    private String value;

    @PostConstruct
    public String getMyName() {
        log.info("value={}", value);
        return value;
    }
}
