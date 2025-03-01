/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package io.gongarce.ud2_mvc.presentation.controller;

import io.gongarce.ud2_mvc.presentation.model.ListModel;
import io.gongarce.ud2_mvc.presentation.model.SinglePropertyModel;
import java.awt.event.ActionEvent;
import java.util.List;
import java.util.Optional;
import javax.swing.AbstractAction;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;
import lombok.RequiredArgsConstructor;

/**
 *
 * @author gag
 */
@RequiredArgsConstructor
public abstract class SearchListController<T> extends AbstractAction {

    private final Document searchInput;
    private final ListModel<T> listModel;
    private final SinglePropertyModel<Boolean> loadingStatusModel;

    public abstract List<T> search(Optional<String> searchText);

    @Override
    public void actionPerformed(ActionEvent e) {
        loadingStatusModel.setProperty(true);
        (new Thread(() -> {
            try {
                listModel.setData(search(getSearchInput()));
            } finally {
                loadingStatusModel.setProperty(false);
            }
        })).start();
    }

    private Optional<String> getSearchInput() {
        try {
            String text = searchInput.getText(0, searchInput.getLength());
            return text.isBlank() ? Optional.empty() : Optional.of(text);
        } catch (BadLocationException e) {
            return Optional.empty();
        }
    }
}
