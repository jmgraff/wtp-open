export default class CheckerTab {

  constructor(scriptName = "check.js") {
    this.reference = undefined;
    this.scriptName = scriptName;
  }

  async createTab() {
    let _this = this;
    return new Promise(function(resolve, reject) {
      chrome.tabs.create({ index: 0, active: false, pinned: true }, function(t) {
        chrome.tabs.onRemoved.addListener(_this.tabRemovedCallback.bind(_this));
        _this.reference = t;
        resolve();
      });
    });
  }

  tabRemovedCallback(tabId) {
    if (this.reference != undefined && this.reference.id == tabId) {
      this.reference = undefined;
    }
  }

  close(){
      if (this.reference != undefined) {
        chrome.tabs.remove(this.reference.id);
      }
  }

  async init() {
    if (this.reference == undefined) {
      await this.createTab();
    }
  }

  async executeScript() {
    let thisTabId = this.reference.id;
    return new Promise(function(resolve,reject) {
      chrome.tabs.executeScript(thisTabId,
        {file: this.scriptName, runAt: "document_end"},
        function() {resolve();});
    }.bind(this));
  }

  async navigate(url) {
    let thisTabId = this.reference.id;
    return new Promise(function(resolve, reject) {
      chrome.tabs.update(thisTabId, {url: url});
      chrome.tabs.onUpdated.addListener(function listener(tabId, changeInfo) {
        if (tabId == thisTabId && changeInfo.status == "complete") {
          chrome.tabs.onUpdated.removeListener(listener);
          resolve();
        }
      })
    });
  }

  async check(url, selector) {
    await this.init();
    await this.navigate(url);
    await this.executeScript();
    let thisTabId = this.reference.id;
    return new Promise(function(resolve,reject) {
      chrome.tabs.sendMessage(thisTabId,
        {type: "check", selector: selector},
        function(response) {
          resolve(response.value);
      });
    });
  }

}
