export default class Gmail {
    constructor() {
      this.authToken = undefined;
    }

    static async getAuthToken() {
      console.log("Getting auth token");
      return new Promise((resolve,reject) => {
        chrome.identity.getAuthToken({interactive: true},(token) => {
          resolve(token);
        })
      });
    }

    async auth() {
      this.authToken = await Gmail.getAuthToken();
    }

    async send(to, subject, content) {
      await this.auth();

      let content_type = "Content-Type: text/plain; charset=utf-8";
      let mime = "MIME-Version: 1.0";
      let email = "";

      email += "To: " + to + "\r\n";
      email += "Subject: " + subject + "\r\n";
      email += content_type + "\r\n";
      email += mime + "\r\n";
      email += "\r\n";
      email += content;

      let base64EncodedEmail = btoa(email).replace(/\+/g, '-').replace(/\//g, '_');

      let message = {
        'raw': base64EncodedEmail
      };

      return new Promise((resolve,reject) => {
        let request = new XMLHttpRequest();

        request.onreadystatechange = () => {
          if (request.readyState !== 4) return;
          if (request.status !== 200) return;
          resolve();
        };

        request.open('POST', 'https://www.googleapis.com/gmail/v1/users/me/messages/send', true);
        request.setRequestHeader('Authorization', 'Bearer ' + this.authToken);
        request.setRequestHeader('Content-Type', 'application/json');
        request.send(JSON.stringify(message));
      });
    }
}
