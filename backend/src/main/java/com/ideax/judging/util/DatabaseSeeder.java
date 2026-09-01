package com.ideax.judging.util;

import com.ideax.judging.config.ApplicationProperties;
import com.ideax.judging.entity.Role;
import com.ideax.judging.entity.User;
import com.ideax.judging.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DatabaseSeeder.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationProperties applicationProperties;

    public DatabaseSeeder(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            ApplicationProperties applicationProperties
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.applicationProperties = applicationProperties;
    }

    @Override
    public void run(String... args) {
        if (!applicationProperties.getAdmin().isSeedEnabled()) {
            log.info("Admin seeding is disabled by configuration");
            return;
        }

        String adminUsername = applicationProperties.getAdmin().getInitialUsername();
        if (!userRepository.existsByUsername(adminUsername)) {
            log.info("No admin user found. Creating initial admin user: {}", adminUsername);
            User admin = new User(
                    adminUsername,
                    passwordEncoder.encode(applicationProperties.getAdmin().getInitialPassword()),
                    Role.ADMIN,
                    true
            );
            userRepository.save(admin);
            log.info("Initial admin account created successfully with username: {}", adminUsername);
        } else {
            log.debug("Admin user {} already exists in database", adminUsername);
        }
    }
}
