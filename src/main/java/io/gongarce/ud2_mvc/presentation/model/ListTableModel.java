package io.gongarce.ud2_mvc.presentation.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.OptionalInt;
import java.util.function.BiConsumer;
import java.util.function.Function;
import java.util.stream.IntStream;
import javax.swing.event.TableModelEvent;
import javax.swing.table.AbstractTableModel;
import lombok.Data;

/**
 *
 * @author Gonzalo
 * @param <T> type of info this model represents
 */
public class ListTableModel<T> extends AbstractTableModel implements ListModel<T>, MasterModel<T> {

    public List<T> data;
    private List<TableColum<T, ?>> columns;

    public ListTableModel() {
        this.columns = new ArrayList<>();
        this.data = new ArrayList<>();
    }

    public ListTableModel(List<TableColum<T, ?>> columns) {
        this.columns = columns;
        this.data = new ArrayList<>();
    }

    public ListTableModel(List<TableColum<T, ?>> columns, List<T> data) {
        this.data = data;
        this.columns = columns;
    }

    public List<T> getData() {
        return data;
    }

    @Override
    public void setData(List<T> data) {
        this.data = data;
        this.fireTableDataChanged();
    }

    public T getRowValue(int rowIndex) {
        return this.data.get(rowIndex);
    }

    public int add(T value) {
        this.data.add(value);
        int rowIndex = this.data.size() - 1;
        this.fireTableRowsInserted(rowIndex, rowIndex);
        return rowIndex;
    }

    public void remove(int index) {
        data.remove(index);
        this.fireTableRowsDeleted(index, index);
    }

    public void remove(Collection<T> toRemove) {
        data.removeAll(toRemove);
        this.fireTableChanged(new TableModelEvent(this));
    }

    @Override
    public void update(T oldModel, T newModel) {
        var rowIndex = data.indexOf(oldModel);
        if (rowIndex > -1) {
            data.set(rowIndex, newModel);
            this.fireTableRowsUpdated(rowIndex, rowIndex);
        }
    }

    @Override
    public int getRowCount() {
        return data.size();
    }

    @Override
    public int getColumnCount() {
        return columns.size();
    }

    @Override
    public String getColumnName(int column) {
        return columns.get(column).getColumName();
    }

    @Override
    public int findColumn(String columnName) {
        OptionalInt result = IntStream.range(0, columns.size())
                .filter(x -> columns.get(x).getColumName().equals(columnName))
                .findFirst();

        if (result.isPresent()) {
            return result.getAsInt();
        }

        return -1;
    }

    @Override
    public Class<?> getColumnClass(int columnIndex) {
        return columns.get(columnIndex).getColumType();
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        return columns.get(columnIndex).getDataGetter().apply(data.get(rowIndex));
    }

    @Override
    public void setValueAt(Object aValue, int rowIndex, int columnIndex) {
        TableColum<T, Object> col = (TableColum<T, Object>) columns.get(columnIndex);
        col.getDataSetter().accept(data.get(rowIndex), col.getColumType().cast(aValue));
        fireTableCellUpdated(rowIndex, columnIndex);
    }

    @Override
    public boolean isCellEditable(int rowIndex, int columnIndex) {
        return columns.get(columnIndex).isEditable();
    }

    @Data
    public static class TableColum<T, R> {

        private final String columName;
        private final Class<R> columType;
        private final Function<T, R> dataGetter;
        private final BiConsumer<T, R> dataSetter;
        private boolean editable;

        public TableColum(String columName, Class<R> columType, Function<T, R> dataGetter, BiConsumer<T, R> dataSetter) {
            this.columName = columName;
            this.columType = columType;
            this.dataGetter = dataGetter;
            this.dataSetter = dataSetter;
            this.editable = true;
        }

        public TableColum(String columName, Class<R> columType, Function<T, R> dataGetter, BiConsumer<T, R> dataSetter, boolean editable) {
            this(columName, columType, dataGetter, dataSetter);
            this.editable = editable;
        }
    }
}
