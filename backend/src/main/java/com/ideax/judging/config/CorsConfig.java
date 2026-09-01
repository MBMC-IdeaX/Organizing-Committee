package com.ideax.judging.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class CorsConfig {

    private final ApplicationProperties applicationProperties;

    public CorsConfig(ApplicationProperties applicationProperties) {
        this.applicationProperties = applicationProperties;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        if (applicationProperties.getCors().getAllowedOriginPatterns() != null && !applicationProperties.getCors().getAllowedOriginPatterns().isEmpty()) {
            configuration.setAllowedOriginPatterns(applicationProperties.getCors().getAllowedOriginPatterns());
        } else {
            configuration.setAllowedOrigins(applicationProperties.getCors().getAllowedOrigins());
        }

        configuration.setAllowedMethods(applicationProperties.getCors().getAllowedMethods());
        
        String headers = applicationProperties.getCors().getAllowedHeaders();
        if (headers == null || headers.trim().isEmpty() || "*".equals(headers.trim())) {
            configuration.setAllowedHeaders(java.util.List.of("*"));
        } else {
            configuration.setAllowedHeaders(java.util.List.of(headers.split(",")));
        }

        configuration.setAllowCredentials(applicationProperties.getCors().isAllowCredentials());
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
