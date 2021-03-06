/*
 * #%L
 * JSQLParser library
 * %%
 * Copyright (C) 2004 - 2013 JSQLParser
 * %%
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Lesser Public License for more details.
 * 
 * You should have received a copy of the GNU General Lesser Public
 * License along with this program.  If not, see
 * <http://www.gnu.org/licenses/lgpl-2.1.html>.
 * #L%
 */
package com.ust.lib.jsqlparser.statement;

import com.ust.lib.jsqlparser.statement.alter.Alter;
import com.ust.lib.jsqlparser.statement.create.index.CreateIndex;
import com.ust.lib.jsqlparser.statement.create.table.CreateTable;
import com.ust.lib.jsqlparser.statement.create.view.AlterView;
import com.ust.lib.jsqlparser.statement.create.view.CreateView;
import com.ust.lib.jsqlparser.statement.delete.Delete;
import com.ust.lib.jsqlparser.statement.drop.Drop;
import com.ust.lib.jsqlparser.statement.execute.Execute;
import com.ust.lib.jsqlparser.statement.insert.Insert;
import com.ust.lib.jsqlparser.statement.merge.Merge;
import com.ust.lib.jsqlparser.statement.replace.Replace;
import com.ust.lib.jsqlparser.statement.select.Select;
import com.ust.lib.jsqlparser.statement.truncate.Truncate;
import com.ust.lib.jsqlparser.statement.update.Update;
import com.ust.lib.jsqlparser.statement.upsert.Upsert;

public class StatementVisitorAdapter implements StatementVisitor {
    @Override
    public void visit(Commit commit) {
        
    }

    @Override
    public void visit(Select select) {

    }

    @Override
    public void visit(Delete delete) {

    }

    @Override
    public void visit(Update update) {

    }

    @Override
    public void visit(Insert insert) {

    }

    @Override
    public void visit(Replace replace) {

    }

    @Override
    public void visit(Drop drop) {

    }

    @Override
    public void visit(Truncate truncate) {

    }

    @Override
    public void visit(CreateIndex createIndex) {

    }

    @Override
    public void visit(CreateTable createTable) {

    }

    @Override
    public void visit(CreateView createView) {

    }

    @Override
    public void visit(Alter alter) {

    }

    @Override
    public void visit(Statements stmts) {
        for (Statement statement : stmts.getStatements()) {
            statement.accept(this);
        }
    }

    @Override
    public void visit(Execute execute) {

    }

    @Override
    public void visit(SetStatement set) {

    }

    @Override
    public void visit(Merge merge) {

    }

    @Override
    public void visit(AlterView alterView) {
    }

    @Override
    public void visit(Upsert upsert) {
        
    }
}
