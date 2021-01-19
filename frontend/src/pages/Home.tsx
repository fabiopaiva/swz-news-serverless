import {useCallback, useEffect, useState} from "react";
import { config } from "../config";
import {Alert, ListGroup, ListGroupItem, ListGroupItemHeading, ListGroupItemText, Spinner} from "reactstrap";
import {News} from "../types/news";
import {Link} from "react-router-dom";

export const Home = () =>  {
  const [news, setNews] = useState<News[]>([]);
  const [error, setError] = useState<string>();
  const [isLoading, setIsloading] = useState<boolean>(true);

  const loadNews = useCallback(async () => {
    try {
      const response = await fetch(`${config.apiBaseUrl}/news`)
      if (!response.ok) {
        setError(`Error fetching data: ${JSON.stringify(await response.json())}`);
      }
      const { data } = await response.json();
      setNews(data);
    } catch (e) {
      setError(e.message);
    } finally {
      setIsloading(false);
    }
  }, []);

  useEffect(() => {
    loadNews();
  }, [loadNews]);

  return (
    <div>
      <h3>News</h3>
      <hr />
      {error && <Alert color="danger">Error: {error}</Alert>}
      {isLoading && <Spinner />}
      {!isLoading && <ListGroup>
        {news.map(item => (
          <ListGroupItem key={item.id}>
            <ListGroupItemHeading tag={Link} to={`/news/${item.slug}`}>{item.title}</ListGroupItemHeading>
            <ListGroupItemText>{item.description.slice(0, 100)}...</ListGroupItemText>
          </ListGroupItem>
        ))}
      </ListGroup>}
    </div>
  );
}
