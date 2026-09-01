package com.ideax.judging.exception;

import org.springframework.http.HttpStatus;

public class DuplicateResourceException extends AppException {
    public DuplicateResourceException(String message) {
        super(message, HttpStatus.CONFLICT, ErrorCode.DUPLICATE_RESOURCE);
    }
}
