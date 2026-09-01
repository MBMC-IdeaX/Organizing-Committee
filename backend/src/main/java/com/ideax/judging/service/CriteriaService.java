package com.ideax.judging.service;

import com.ideax.judging.dto.request.CreateCriteriaRequest;
import com.ideax.judging.dto.request.UpdateCriteriaRequest;
import com.ideax.judging.dto.response.CriteriaResponse;
import com.ideax.judging.entity.Criteria;
import com.ideax.judging.exception.ResourceNotFoundException;
import com.ideax.judging.mapper.CriteriaMapper;
import com.ideax.judging.repository.CriteriaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CriteriaService {

    private static final Logger log = LoggerFactory.getLogger(CriteriaService.class);

    private final CriteriaRepository criteriaRepository;
    private final CriteriaMapper criteriaMapper;

    public CriteriaService(CriteriaRepository criteriaRepository, CriteriaMapper criteriaMapper) {
        this.criteriaRepository = criteriaRepository;
        this.criteriaMapper = criteriaMapper;
    }

    @Transactional(readOnly = true)
    public List<CriteriaResponse> getAllCriteria() {
        return criteriaRepository.findAllByOrderByDisplayOrderAsc()
                .stream()
                .map(criteriaMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public CriteriaResponse getCriteriaById(Long id) {
        Criteria criteria = criteriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Criteria not found with id: " + id));
        return criteriaMapper.toResponse(criteria);
    }

    @Transactional
    public CriteriaResponse createCriteria(CreateCriteriaRequest request) {
        Criteria criteria = new Criteria(
                request.getName().trim(),
                request.getDescription() != null ? request.getDescription().trim() : null,
                request.getMaxScore(),
                request.getDisplayOrder() != null ? request.getDisplayOrder() : 0,
                true
        );

        Criteria saved = criteriaRepository.save(criteria);
        log.info("Admin created criteria id: {}, name: {}, maxScore: {}", saved.getId(), saved.getName(), saved.getMaxScore());
        return criteriaMapper.toResponse(saved);
    }

    @Transactional
    public CriteriaResponse updateCriteria(Long id, UpdateCriteriaRequest request) {
        Criteria criteria = criteriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Criteria not found with id: " + id));

        criteria.setName(request.getName().trim());
        criteria.setDescription(request.getDescription() != null ? request.getDescription().trim() : null);
        criteria.setMaxScore(request.getMaxScore());
        if (request.getDisplayOrder() != null) {
            criteria.setDisplayOrder(request.getDisplayOrder());
        }

        Criteria updated = criteriaRepository.save(criteria);
        log.info("Admin updated criteria id: {}, name: {}", updated.getId(), updated.getName());
        return criteriaMapper.toResponse(updated);
    }

    @Transactional
    public CriteriaResponse updateCriteriaStatus(Long id, boolean active) {
        Criteria criteria = criteriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Criteria not found with id: " + id));

        criteria.setActive(active);
        Criteria updated = criteriaRepository.save(criteria);
        log.info("Admin updated criteria id: {} status to active={}", updated.getId(), active);
        return criteriaMapper.toResponse(updated);
    }

    @Transactional
    public List<CriteriaResponse> reorderCriteria(List<Long> orderedIds) {
        log.info("Admin reordering criteria with order: {}", orderedIds);
        for (int i = 0; i < orderedIds.size(); i++) {
            Long id = orderedIds.get(i);
            Criteria criteria = criteriaRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Criteria not found with id: " + id));
            criteria.setDisplayOrder(i + 1);
            criteriaRepository.save(criteria);
        }
        return getAllCriteria();
    }

    @Transactional(readOnly = true)
    public int getTotalMaxScore() {
        Long sum = criteriaRepository.sumMaxScoreByActiveTrue();
        return sum != null ? sum.intValue() : 0;
    }
}
