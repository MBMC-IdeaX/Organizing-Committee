package com.ideax.judging.dto.request;

import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class ReorderRequest {

    @NotEmpty(message = "Ordered IDs list cannot be empty")
    private List<Long> orderedIds;

    public ReorderRequest() {
    }

    public ReorderRequest(List<Long> orderedIds) {
        this.orderedIds = orderedIds;
    }

    public List<Long> getOrderedIds() {
        return orderedIds;
    }

    public void setOrderedIds(List<Long> orderedIds) {
        this.orderedIds = orderedIds;
    }
}
