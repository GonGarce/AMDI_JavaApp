/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package io.gongarce.ud2_mvc.infra.jdbc.mappers;

import io.gongarce.ud2_mvc.domain.mail.Mail;
import io.gongarce.ud2_mvc.domain.person.Person;
import io.gongarce.ud2_mvc.infra.jdbc.entities.MailEntity;
import io.gongarce.ud2_mvc.infra.jdbc.entities.PersonEntity;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 *
 * @author Gonzalo
 */
@Mapper
public interface PersonEntityMapper {

    PersonEntityMapper INSTANCE = Mappers.getMapper(PersonEntityMapper.class);

    @Mapping(target = "withPlace", ignore = true)
    Person toDomain(PersonEntity p);

    List<Person> toDomain(List<PersonEntity> persons);

    Mail toDomain(MailEntity m);

    PersonEntity toEntity(Person p);

    @Mapping(target = "person", ignore = true)
    MailEntity toEntity(Mail m);
}
