package com.catai.service;

import com.catai.dto.request.PetRequest;
import com.catai.dto.response.PetResponse;
import com.catai.entity.Pet;
import com.catai.exception.ResourceNotFoundException;
import com.catai.exception.UnauthorizedException;
import com.catai.repository.GrowthRecordRepository;
import com.catai.repository.HealthReminderRepository;
import com.catai.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;
    private final GrowthRecordRepository growthRecordRepository;
    private final HealthReminderRepository healthReminderRepository;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public List<PetResponse> getUserPets(String userId) {
        return petRepository.findByUserIdOrderByUpdateTimeDesc(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public PetResponse getPet(String petId, String userId) {
        Pet pet = findPetOwnedByUser(petId, userId);
        return toResponse(pet);
    }

    @Transactional
    public PetResponse createPet(String userId, PetRequest req) {
        String today = LocalDate.now().format(DATE_FMT);
        Pet pet = Pet.builder()
                .id(UUID.randomUUID().toString())
                .userId(userId)
                .name(req.getName())
                .species(req.getSpecies() != null ? req.getSpecies() : "")
                .breed(req.getBreed() != null ? req.getBreed() : "")
                .birthDate(req.getBirthDate() != null ? req.getBirthDate() : "")
                .gender(req.getGender() != null ? req.getGender() : "")
                .avatar(req.getAvatar() != null ? req.getAvatar() : "")
                .weight(req.getWeight() != null ? req.getWeight() : 0.0)
                .height(req.getHeight() != null ? req.getHeight() : 0.0)
                .color(req.getColor() != null ? req.getColor() : "")
                .notes(req.getNotes() != null ? req.getNotes() : "")
                .createTime(today)
                .updateTime(today)
                .build();

        petRepository.save(pet);
        return toResponse(pet);
    }

    @Transactional
    public PetResponse updatePet(String petId, String userId, PetRequest req) {
        Pet pet = findPetOwnedByUser(petId, userId);

        pet.setName(req.getName());
        if (req.getSpecies() != null) pet.setSpecies(req.getSpecies());
        if (req.getBreed() != null) pet.setBreed(req.getBreed());
        if (req.getBirthDate() != null) pet.setBirthDate(req.getBirthDate());
        if (req.getGender() != null) pet.setGender(req.getGender());
        if (req.getAvatar() != null) pet.setAvatar(req.getAvatar());
        if (req.getWeight() != null) pet.setWeight(req.getWeight());
        if (req.getHeight() != null) pet.setHeight(req.getHeight());
        if (req.getColor() != null) pet.setColor(req.getColor());
        if (req.getNotes() != null) pet.setNotes(req.getNotes());
        pet.setUpdateTime(LocalDate.now().format(DATE_FMT));

        petRepository.save(pet);
        return toResponse(pet);
    }

    @Transactional
    public void deletePet(String petId, String userId) {
        Pet pet = findPetOwnedByUser(petId, userId);
        // Cascade delete related records
        growthRecordRepository.deleteByPetId(petId);
        healthReminderRepository.deleteByPetId(petId);
        petRepository.delete(pet);
    }

    private Pet findPetOwnedByUser(String petId, String userId) {
        Pet pet = petRepository.findById(petId)
                .orElseThrow(() -> new ResourceNotFoundException("宠物", petId));
        if (!pet.getUserId().equals(userId)) {
            throw new UnauthorizedException("无权访问此宠物");
        }
        return pet;
    }

    private PetResponse toResponse(Pet pet) {
        return PetResponse.builder()
                .id(pet.getId())
                .userId(pet.getUserId())
                .name(pet.getName())
                .species(pet.getSpecies())
                .breed(pet.getBreed())
                .birthDate(pet.getBirthDate())
                .gender(pet.getGender())
                .avatar(pet.getAvatar())
                .weight(pet.getWeight())
                .height(pet.getHeight())
                .color(pet.getColor())
                .notes(pet.getNotes())
                .createTime(pet.getCreateTime())
                .updateTime(pet.getUpdateTime())
                .build();
    }
}
