import { socket } from '@kit.NetworkKit';
import { keyDown, keyUp, textMsg, DELIMITER } from './Protocol';

export type ConnState = 'idle' | 'listening' | 'connected' | 'error';

/**
 * 有线(TCP) 连接服务：在平板上起 TCP 服务端监听 5959 端口。
 * 电脑通过 `hdc fport tcp:5959 tcp:5959` 转发后，用 receiver.py --tcp 连入。
 * 按键以换行分隔 JSON 报文发送，由电脑端 receiver.py 注入成真键盘输入。
 */
export class ConnectionService {
  private server: socket.TCPSocketServer | null = null;
  private client: socket.TCPSocketConnection | null = null;
  state: ConnState = 'idle';
  onStateChange: (s: ConnState) => void = () => {
  };

  start(): void {
    if (this.server !== null) {
      return;
    }
    let server: socket.TCPSocketServer;
    try {
      server = socket.constructTCPSocketServerInstance();
    } catch (e) {
      this.setState('error');
      return;
    }
    this.server = server;
    let addr: socket.NetAddress = { address: '0.0.0.0', port: 5959, family: 1 };
    server.listen(addr, (err) => {
      if (err) {
        this.setState('error');
        return;
      }
      this.setState('listening');
    });
    server.on('connect', (client) => {
      // 新连接进来时，主动关掉旧连接，避免多个客户端抢占导致状态错乱
      if (this.client !== null) {
        this.client.close();
      }
      this.client = client;
      this.setState('connected');
      client.on('close', () => {
        // 只有当前连接断开才清空，旧连接的后发 close 事件不能误清
        if (this.client === client) {
          this.client = null;
          this.setState('listening');
        }
      });
    });
  }

  stop(): void {
    if (this.client !== null) {
      this.client.close();
      this.client = null;
    }
    if (this.server !== null) {
      this.server.close();
      this.server = null;
    }
    this.setState('idle');
  }

  send(name: string, down: boolean): void {
    if (this.client === null) {
      return;
    }
    let msg: string = down ? keyDown(name) : keyUp(name);
    this.client.send({ data: msg + DELIMITER }, (err) => {
    });
  }

  sendText(text: string): void {
    if (this.client === null) {
      return;
    }
    this.client.send({ data: textMsg(text) + DELIMITER }, (err) => {
    });
  }

  isConnected(): boolean {
    return this.client !== null;
  }

  private setState(s: ConnState): void {
    this.state = s;
    this.onStateChange(s);
  }
}
