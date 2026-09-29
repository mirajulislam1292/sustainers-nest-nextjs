type PageIntroProps = {
  index: string;
  title: string;
  description: string;
};

export function PageIntro({ index, title, description }: PageIntroProps) {
  return (
    <header className="page-intro">
      <div className="site-container page-intro-grid">
        <p>{index}</p>
        <h1>{title}</h1>
        <p>{description}</p>
      </div>
    </header>
  );
}
