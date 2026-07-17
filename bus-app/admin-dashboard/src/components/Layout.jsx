import Sidebar from './Sidebar';

export default function Layout({ children }) {
  return (
    <div style={{ display: 'flex' }}>
      <Sidebar />
      <div style={{ marginLeft: 240, padding: '30px 36px', width: '100%', minHeight: '100vh' }}>
        {children}
      </div>
    </div>
  );
}