package com.ideax.judging.exception;

import org.springframework.http.HttpStatus;

public class InvalidScoreException extends AppException {
    public InvalidScoreException(String message) {
        super(message, HttpStatus.BAD_REQUEST, ErrorCode.INVALID_SCORE);
    }
}
