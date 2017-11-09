package com.ust.model;

import java.io.Serializable;
import java.util.List;


public class ResponseModel implements Serializable{
	private List<String> srctableList;
	public List<String> getTartableList() {
		return tartableList;
	}
	public void setTartableList(List<String> tartableList) {
		this.tartableList = tartableList;
	}
	private List<String> tartableList;
	public List<String> getSrctableList() {
		return srctableList;
	}
	public void setSrctableList(List<String> srctableList) {
		this.srctableList = srctableList;
	}
	private List<CodeBlockModel> codeBlocks;
	private String fileContent;
	private String completeGraph;
	
	public List<CodeBlockModel> getCodeBlocks() {
		return codeBlocks;
	}
	public void setCodeBlocks(List<CodeBlockModel> codeBlockList) {
		this.codeBlocks = codeBlockList;
	}
	public String getFileContent() {
		return fileContent;
	}
	public void setFileContent(String fileContent) {
		this.fileContent = fileContent;
	}
	public String getCompleteGraph() {
		return completeGraph;
	}
	public void setCompleteGraph(String completeGraph) {
		this.completeGraph = completeGraph;
	}
}
